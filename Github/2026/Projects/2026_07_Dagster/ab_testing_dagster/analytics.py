import numpy as np
import pandas as pd

from dagster import asset, AssetExecutionContext, AssetCheckResult, asset_check

from .assets import SRM_ALPHA, SIGNIFICANCE_ALPHA, EXPERIMENT_DAYS
from .db import get_connection, read_sql
from .stats_utils import (
    srm_p_value,
    cuped_adjust,
    welch_test,
    mean_diff_ci,
    cohens_d,
    cohens_h,
    posthoc_power,
    always_valid_p_and_ci,
)

SEQ_ALPHA = 0.05
SEQ_TAU = 0.01
N_QUARTILES = 4


@asset(
    deps=["fct_experiment_users"],
    group_name="analytics",
    compute_kind="python",
)
def ab_test_revenue_metrics(context: AssetExecutionContext):
    """CUPED-adjusted revenue-per-user analysis with Cohen's d."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, revenue, pre_exp_purchases, is_treatment"
            " FROM fct_experiment_users",
        )

    srm_p = srm_p_value(df["variant"].value_counts())

    df["revenue_cuped"] = cuped_adjust(df, "revenue")

    control = df.loc[~df["is_treatment"].astype(bool), "revenue_cuped"]
    treatment = df.loc[df["is_treatment"].astype(bool), "revenue_cuped"]
    test = welch_test(control, treatment)
    ci_lower, ci_upper = mean_diff_ci(control, treatment, SIGNIFICANCE_ALPHA)

    rev_control = df.loc[~df["is_treatment"].astype(bool), "revenue"].mean()
    rev_treatment = df.loc[df["is_treatment"].astype(bool), "revenue"].mean()
    lift_pct = (rev_treatment - rev_control) / rev_control * 100 if rev_control > 0 else 0.0
    d = cohens_d(control, treatment)
    power = posthoc_power(test["diff"], len(control), len(treatment), SIGNIFICANCE_ALPHA)

    context.add_output_metadata({
        "srm_p_value": srm_p,
        "srm_passed": bool(srm_p > SRM_ALPHA),
        "revenue_p_value": test["p_value"],
        "statistically_significant": bool(test["p_value"] < SIGNIFICANCE_ALPHA),
        "sample_size": len(df),
        "lift_pct": float(lift_pct),
        "ci_lower": ci_lower,
        "ci_upper": ci_upper,
        "cohens_d": d,
        "power_estimate": power,
        "mean_revenue_control": float(rev_control),
        "mean_revenue_treatment": float(rev_treatment),
    })


@asset_check(asset=ab_test_revenue_metrics, blocking=True)
def srm_check_revenue():
    with get_connection(read_only=True) as con:
        df = read_sql(con, "SELECT variant FROM fct_experiment_users")

    p = srm_p_value(df["variant"].value_counts())
    return AssetCheckResult(
        passed=bool(p > SRM_ALPHA),
        metadata={"srm_p_value": p, "threshold": SRM_ALPHA},
    )


@asset(
    deps=["fct_experiment_users"],
    group_name="analytics",
    compute_kind="python",
)
def ab_test_segment_metrics(context: AssetExecutionContext):
    """Conversion analysis segmented by pre-experiment purchase quartile."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, converted, pre_exp_purchases, is_treatment"
            " FROM fct_experiment_users",
        )

    srm_p = srm_p_value(df["variant"].value_counts())

    df["quartile"] = pd.qcut(
        df["pre_exp_purchases"], N_QUARTILES, labels=False, duplicates="drop"
    )

    metadata = {
        "srm_p_value": srm_p,
        "srm_passed": bool(srm_p > SRM_ALPHA),
        "n_segments": int(df["quartile"].nunique()),
    }

    for q in sorted(df["quartile"].unique()):
        seg = df[df["quartile"] == q]
        control = seg.loc[~seg["is_treatment"].astype(bool), "converted"]
        treatment = seg.loc[seg["is_treatment"].astype(bool), "converted"]

        if len(control) < 2 or len(treatment) < 2:
            continue

        test = welch_test(control, treatment)
        p_c = control.mean()
        p_t = treatment.mean()
        lift = (p_t - p_c) / p_c * 100 if p_c > 0 else 0.0
        h = cohens_h(p_t, p_c)

        metadata[f"q{q}_p_value"] = test["p_value"]
        metadata[f"q{q}_lift_pct"] = float(lift)
        metadata[f"q{q}_cohens_h"] = h
        metadata[f"q{q}_n"] = len(seg)
        metadata[f"q{q}_significant"] = bool(test["p_value"] < SIGNIFICANCE_ALPHA)

    context.add_output_metadata(metadata)


@asset_check(asset=ab_test_segment_metrics, blocking=True)
def srm_check_segments():
    with get_connection(read_only=True) as con:
        df = read_sql(con, "SELECT variant FROM fct_experiment_users")

    p = srm_p_value(df["variant"].value_counts())
    return AssetCheckResult(
        passed=bool(p > SRM_ALPHA),
        metadata={"srm_p_value": p, "threshold": SRM_ALPHA},
    )


@asset(
    deps=["fct_experiment_users"],
    group_name="sequential",
    compute_kind="python",
)
def ab_test_sequential_metrics(context: AssetExecutionContext):
    """Always-valid inference via Gaussian-mixture mSPRT over daily looks."""
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, converted, arrived_at, is_treatment"
            " FROM fct_experiment_users",
        )

    srm_p = srm_p_value(df["variant"].value_counts())

    daily_stats = []
    for day in range(1, EXPERIMENT_DAYS + 1):
        cumulative = df[df["arrived_at"] <= day]
        c = cumulative.loc[~cumulative["is_treatment"].astype(bool), "converted"]
        t = cumulative.loc[cumulative["is_treatment"].astype(bool), "converted"]

        daily_stats.append({
            "n_c": len(c),
            "n_t": len(t),
            "mean_c": float(c.mean()) if len(c) > 0 else 0.0,
            "mean_t": float(t.mean()) if len(t) > 0 else 0.0,
            "var_c": float(c.var()) if len(c) > 1 else 0.0,
            "var_t": float(t.var()) if len(t) > 1 else 0.0,
        })

    result = always_valid_p_and_ci(daily_stats, tau=SEQ_TAU, alpha=SEQ_ALPHA)

    context.add_output_metadata({
        "srm_p_value": srm_p,
        "srm_passed": bool(srm_p > SRM_ALPHA),
        "can_stop_early": result["can_stop_early"],
        "earliest_stop_day": result["earliest_stop_day"],
        "final_always_valid_p": result["final_always_valid_p"],
        "final_ci_lower": result["final_ci_lower"],
        "final_ci_upper": result["final_ci_upper"],
        "n_looks": EXPERIMENT_DAYS,
    })


@asset_check(asset=ab_test_sequential_metrics, blocking=True)
def srm_check_sequential():
    with get_connection(read_only=True) as con:
        df = read_sql(con, "SELECT variant FROM fct_experiment_users")

    p = srm_p_value(df["variant"].value_counts())
    return AssetCheckResult(
        passed=bool(p > SRM_ALPHA),
        metadata={"srm_p_value": p, "threshold": SRM_ALPHA},
    )
