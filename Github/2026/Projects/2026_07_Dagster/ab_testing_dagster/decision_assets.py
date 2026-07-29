from pathlib import Path

import numpy as np
from jinja2 import Environment, FileSystemLoader

from dagster import asset, AssetExecutionContext, AssetCheckResult, asset_check

from .db import get_connection, read_sql
from .decision_engine import decide
from .experiment_config import config
from .guardrails import guardrail_test
from .notifications import AlertPayload, send_slack_alert, should_alert
from .stats_utils import srm_p_value, welch_test, mean_diff_ci, posthoc_power

TEMPLATES_DIR = Path(__file__).joinpath("..", "..", "templates").resolve()
REPORTS_DIR = Path(__file__).joinpath("..", "..", "reports").resolve()


@asset(
    deps=["ab_test_summary_metrics", "ab_test_sequential_metrics", "ab_test_revenue_metrics"],
    group_name="decision",
    compute_kind="python",
)
def experiment_decision(context: AssetExecutionContext):
    """Synthesizes all analytics into a ship/hold/kill verdict."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, converted, revenue, pre_exp_purchases, is_treatment"
            " FROM fct_experiment_users",
        )

    is_t = df["is_treatment"].astype(bool)
    control = df.loc[~is_t, "converted"]
    treatment = df.loc[is_t, "converted"]

    test = welch_test(control, treatment)
    ci_lower, ci_upper = mean_diff_ci(control, treatment, config.alpha)
    power = posthoc_power(test["diff"], len(control), len(treatment), config.alpha)

    guardrail_results = []
    for metric_name in config.guardrail_metrics:
        col = "revenue" if metric_name == "revenue_per_user" else "converted"
        g_control = df.loc[~is_t, col]
        g_treatment = df.loc[is_t, col]
        margin_abs = config.guardrail_margin * g_control.mean()
        result = guardrail_test(g_control, g_treatment, margin=margin_abs, alpha=config.alpha)
        guardrail_results.append({"name": metric_name, **result})

    all_guardrails_passed = all(g["passed"] for g in guardrail_results)

    decision = decide(
        p_value=test["p_value"],
        ci_lower=ci_lower,
        ci_upper=ci_upper,
        power=power,
        alpha=config.alpha,
        target_power=config.target_power,
        guardrail_passed=all_guardrails_passed,
        sequential_can_stop=False,
    )

    context.add_output_metadata({
        "verdict": decision.verdict,
        "confidence_level": decision.confidence_level,
        "reasons": decision.reasons,
        "p_value": test["p_value"],
        "power": power,
        "guardrails_passed": all_guardrails_passed,
    })

    context.log.info(
        "decision_made",
        extra={"verdict": decision.verdict, "confidence": decision.confidence_level},
    )

    if should_alert(decision.verdict) and config.notifications.slack_webhook_url:
        alert = AlertPayload(
            experiment_name=config.name,
            verdict=decision.verdict,
            confidence_level=decision.confidence_level,
            reasons=decision.reasons,
            slack_channel=config.notifications.slack_channel,
        )
        sent = send_slack_alert(config.notifications.slack_webhook_url, alert)
        context.log.info("slack_alert_sent", extra={"success": sent})


@asset_check(asset=experiment_decision, blocking=True)
def guardrail_check():
    """Fails if any guardrail metric is violated."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, revenue, converted, is_treatment"
            " FROM fct_experiment_users",
        )

    is_t = df["is_treatment"].astype(bool)
    results = {}
    all_passed = True

    for metric_name in config.guardrail_metrics:
        col = "revenue" if metric_name == "revenue_per_user" else "converted"
        g_control = df.loc[~is_t, col]
        g_treatment = df.loc[is_t, col]
        margin_abs = config.guardrail_margin * g_control.mean()
        result = guardrail_test(g_control, g_treatment, margin=margin_abs, alpha=config.alpha)
        results[metric_name] = result
        if not result["passed"]:
            all_passed = False

    return AssetCheckResult(
        passed=all_passed,
        metadata={
            f"{name}_p_value": r["p_value"]
            for name, r in results.items()
        },
    )


@asset(
    deps=["ab_test_revenue_metrics"],
    group_name="decision",
    compute_kind="python",
)
def revenue_impact(context: AssetExecutionContext):
    """Projects annualized revenue delta with confidence interval."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT revenue, is_treatment FROM fct_experiment_users",
        )

    is_t = df["is_treatment"].astype(bool)
    control = df.loc[~is_t, "revenue"]
    treatment = df.loc[is_t, "revenue"]

    ci_lower, ci_upper = mean_diff_ci(control, treatment, config.alpha)
    diff = treatment.mean() - control.mean()

    daily_users = config.revenue.daily_users
    annualized_delta = diff * daily_users * 365
    annualized_lower = ci_lower * daily_users * 365
    annualized_upper = ci_upper * daily_users * 365

    daily_delta = diff * daily_users
    payback_days = (
        config.revenue.implementation_cost / daily_delta
        if daily_delta > 0
        else float("inf")
    )

    context.add_output_metadata({
        "delta_rev_per_user": float(diff),
        "annualized_delta_usd": float(annualized_delta),
        "ci_lower_usd": float(annualized_lower),
        "ci_upper_usd": float(annualized_upper),
        "payback_days": float(payback_days),
        "implementation_cost": config.revenue.implementation_cost,
    })

    context.log.info(
        "revenue_impact_computed",
        extra={"annualized_usd": annualized_delta, "payback_days": payback_days},
    )


@asset(
    deps=["experiment_decision", "revenue_impact"],
    group_name="reporting",
    compute_kind="python",
)
def experiment_report(context: AssetExecutionContext):
    """Generates a stakeholder-ready markdown report."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, converted, revenue, pre_exp_purchases, is_treatment, arrived_at"
            " FROM fct_experiment_users",
        )

    is_t = df["is_treatment"].astype(bool)

    control_conv = df.loc[~is_t, "converted"]
    treatment_conv = df.loc[is_t, "converted"]
    conv_test = welch_test(control_conv, treatment_conv)
    conv_ci = mean_diff_ci(control_conv, treatment_conv, config.alpha)
    conv_power = posthoc_power(conv_test["diff"], len(control_conv), len(treatment_conv), config.alpha)
    p_c = control_conv.mean()
    p_t = treatment_conv.mean()
    conv_lift = (p_t - p_c) / p_c * 100 if p_c > 0 else 0.0

    from .stats_utils import cohens_h
    h = cohens_h(p_t, p_c)

    control_rev = df.loc[~is_t, "revenue"]
    treatment_rev = df.loc[is_t, "revenue"]
    rev_ci = mean_diff_ci(control_rev, treatment_rev, config.alpha)
    rev_diff = treatment_rev.mean() - control_rev.mean()

    daily_users = config.revenue.daily_users
    annualized = rev_diff * daily_users * 365
    daily_delta = rev_diff * daily_users
    payback = config.revenue.implementation_cost / daily_delta if daily_delta > 0 else float("inf")

    guardrail_results = []
    for metric_name in config.guardrail_metrics:
        col = "revenue" if metric_name == "revenue_per_user" else "converted"
        g_control = df.loc[~is_t, col]
        g_treatment = df.loc[is_t, col]
        margin_abs = config.guardrail_margin * g_control.mean()
        result = guardrail_test(g_control, g_treatment, margin=margin_abs, alpha=config.alpha)
        guardrail_results.append({"name": metric_name, **result})

    all_guardrails_passed = all(g["passed"] for g in guardrail_results)
    decision = decide(
        p_value=conv_test["p_value"],
        ci_lower=conv_ci[0],
        ci_upper=conv_ci[1],
        power=conv_power,
        alpha=config.alpha,
        target_power=config.target_power,
        guardrail_passed=all_guardrails_passed,
    )

    env = Environment(loader=FileSystemLoader(str(TEMPLATES_DIR)), autoescape=False)
    template = env.get_template("report.md.j2")

    report = template.render(
        experiment_name=config.name,
        owner=config.owner,
        duration_days=config.duration_days,
        sample_size=len(df),
        verdict=decision.verdict,
        reasons=decision.reasons,
        conversion={
            "p_value": f"{conv_test['p_value']:.6f}",
            "lift_pct": f"{conv_lift:.2f}",
            "ci_lower": f"{conv_ci[0]:.6f}",
            "ci_upper": f"{conv_ci[1]:.6f}",
            "cohens_h": f"{h:.4f}",
            "power": f"{conv_power:.3f}",
        },
        revenue={
            "annualized_delta_usd": f"{annualized:,.0f}",
            "ci_lower_usd": f"{rev_ci[0] * daily_users * 365:,.0f}",
            "ci_upper_usd": f"{rev_ci[1] * daily_users * 365:,.0f}",
            "payback_days": f"{payback:.0f}" if payback != float("inf") else "N/A",
        },
        guardrails=[
            {
                "name": g["name"],
                "passed": g["passed"],
                "p_value": f"{g['p_value']:.4f}",
                "ci_lower": f"{g['ci_lower']:.4f}",
            }
            for g in guardrail_results
        ],
        sequential={
            "can_stop_early": "See sequential asset",
            "earliest_stop_day": "See sequential asset",
            "final_p": "See sequential asset",
        },
    )

    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    report_path = REPORTS_DIR / "latest_experiment_report.md"
    report_path.write_text(report)

    context.add_output_metadata({
        "report_path": str(report_path),
        "verdict": decision.verdict,
        "report_length_chars": len(report),
    })
