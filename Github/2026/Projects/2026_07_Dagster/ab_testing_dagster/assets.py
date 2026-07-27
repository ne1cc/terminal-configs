import duckdb
import numpy as np
import pandas as pd
import scipy.stats as stats
from pathlib import Path

from dagster import asset, AssetExecutionContext, AssetCheckResult, asset_check
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject

from .stats_utils import srm_p_value, cuped_adjust, welch_test, mean_diff_ci, cohens_h, posthoc_power

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
DB_PATH = DBT_PROJECT_DIR / "dev.duckdb"
SRM_ALPHA = 0.01
SIGNIFICANCE_ALPHA = 0.05
EXPERIMENT_DAYS = 28

dbt_project = DbtProject(project_dir=DBT_PROJECT_DIR)
dbt_project.prepare_if_dev()


@asset(group_name="ingestion", compute_kind="python")
def raw_experiment_events():
    """Generates synthetic user telemetry events and writes them to DuckDB."""
    rng = np.random.default_rng(42)
    n_users = 50000

    users = pd.DataFrame({
        "user_id": np.arange(1, n_users + 1),
        "variant": rng.choice(
            ["control", "treatment"], size=n_users, p=[0.5, 0.5]
        ),
        "pre_exp_purchases": rng.poisson(lam=1.2, size=n_users),
    })

    probs = np.where(users["variant"] == "treatment", 0.12 + 0.035, 0.12)
    users["converted"] = rng.binomial(1, probs)

    base_revenue = rng.lognormal(mean=2.5, sigma=0.8, size=n_users)
    treatment_mult = np.where(users["variant"] == "treatment", 1.15, 1.0)
    users["revenue"] = users["converted"] * base_revenue * treatment_mult

    users["arrived_at"] = rng.integers(1, EXPERIMENT_DAYS + 1, size=n_users)

    with duckdb.connect(str(DB_PATH)) as con:
        con.register("users_df", users)
        con.execute(
            "CREATE OR REPLACE TABLE stg_raw_events AS SELECT * FROM users_df"
        )


@dbt_assets(manifest=dbt_project.manifest_path)
def my_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


@asset(
    deps=["fct_experiment_users"],
    group_name="analytics",
    compute_kind="python",
)
def ab_test_summary_metrics(context: AssetExecutionContext):
    """Pulls modeled dbt mart data, checks for SRM, and runs CUPED-adjusted t-test."""
    with duckdb.connect(str(DB_PATH), read_only=True) as con:
        df = con.execute(
            "SELECT variant, converted, pre_exp_purchases, is_treatment"
            " FROM fct_experiment_users"
        ).df()

    srm_p = srm_p_value(df["variant"].value_counts())

    df["converted_cuped"] = cuped_adjust(df, "converted")

    control = df.loc[~df["is_treatment"].astype(bool), "converted_cuped"]
    treatment = df.loc[df["is_treatment"].astype(bool), "converted_cuped"]
    test = welch_test(control, treatment)
    ci_lower, ci_upper = mean_diff_ci(control, treatment, SIGNIFICANCE_ALPHA)

    p_control = df.loc[~df["is_treatment"].astype(bool), "converted"].mean()
    p_treatment = df.loc[df["is_treatment"].astype(bool), "converted"].mean()
    lift_pct = (p_treatment - p_control) / p_control * 100 if p_control > 0 else 0.0
    h = cohens_h(p_treatment, p_control)
    power = posthoc_power(test["diff"], len(control), len(treatment), SIGNIFICANCE_ALPHA)

    context.add_output_metadata({
        "srm_p_value": srm_p,
        "srm_passed": bool(srm_p > SRM_ALPHA),
        "cuped_p_value": test["p_value"],
        "statistically_significant": bool(test["p_value"] < SIGNIFICANCE_ALPHA),
        "sample_size": len(df),
        "lift_pct": float(lift_pct),
        "ci_lower": ci_lower,
        "ci_upper": ci_upper,
        "cohens_h": h,
        "power_estimate": power,
    })


@asset_check(asset=ab_test_summary_metrics, blocking=True)
def srm_check():
    """Fails the pipeline if sample ratio mismatch is detected."""
    with duckdb.connect(str(DB_PATH), read_only=True) as con:
        df = con.execute(
            "SELECT variant FROM fct_experiment_users"
        ).df()

    observed = df["variant"].value_counts()
    _, p_value = stats.chisquare(observed)

    return AssetCheckResult(
        passed=bool(p_value > SRM_ALPHA),
        metadata={
            "srm_p_value": float(p_value),
            "threshold": SRM_ALPHA,
            "control_n": int(observed.get("control", 0)),
            "treatment_n": int(observed.get("treatment", 0)),
        },
    )
