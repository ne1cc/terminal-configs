import duckdb
import numpy as np
import pandas as pd
import scipy.stats as stats
from pathlib import Path

from dagster import asset, AssetExecutionContext, AssetCheckResult, asset_check
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
DB_PATH = DBT_PROJECT_DIR / "dev.duckdb"
SRM_ALPHA = 0.01
SIGNIFICANCE_ALPHA = 0.05

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

    observed = df["variant"].value_counts()
    _, srm_p_value = stats.chisquare(observed)

    theta = (
        df["converted"].cov(df["pre_exp_purchases"])
        / df["pre_exp_purchases"].var()
    )
    df["converted_cuped"] = df["converted"] - theta * (
        df["pre_exp_purchases"] - df["pre_exp_purchases"].mean()
    )

    control = df.loc[~df["is_treatment"].astype(bool), "converted_cuped"]
    treatment = df.loc[df["is_treatment"].astype(bool), "converted_cuped"]
    _, p_val = stats.ttest_ind(control, treatment, equal_var=False)

    context.add_output_metadata({
        "srm_p_value": float(srm_p_value),
        "srm_passed": bool(srm_p_value > SRM_ALPHA),
        "cuped_p_value": float(p_val),
        "statistically_significant": bool(p_val < SIGNIFICANCE_ALPHA),
        "sample_size": len(df),
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
