import duckdb
import numpy as np
import pandas as pd
import scipy.stats as stats
from pathlib import Path

from dagster import asset, AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
dbt_project = DbtProject(project_dir=DBT_PROJECT_DIR)
dbt_project.prepare_if_dev()


@asset(group_name="ingestion", compute_kind="python")
def raw_experiment_events() -> str:
    """Generates synthetic user telemetry events and writes them to DuckDB."""
    np.random.seed(42)
    n_users = 50000

    users = pd.DataFrame({
        "user_id": np.arange(1, n_users + 1),
        "variant": np.random.choice(
            ["control", "treatment"], size=n_users, p=[0.5, 0.5]
        ),
        "pre_exp_purchases": np.random.poisson(lam=1.2, size=n_users),
    })

    users["converted"] = np.where(
        users["variant"] == "treatment",
        np.random.binomial(1, 0.12 + 0.035, n_users),
        np.random.binomial(1, 0.12, n_users),
    )

    db_path = DBT_PROJECT_DIR / "dev.duckdb"
    con = duckdb.connect(str(db_path))
    con.execute("CREATE OR REPLACE TABLE stg_raw_events AS SELECT * FROM users")
    con.close()

    return str(db_path)


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
    db_path = DBT_PROJECT_DIR / "dev.duckdb"
    con = duckdb.connect(str(db_path))
    df = con.execute("SELECT * FROM fct_experiment_users").df()
    con.close()

    observed = df["variant"].value_counts()
    _, srm_p_value = stats.chisquare(observed)

    theta = (
        df["converted"].cov(df["pre_exp_purchases"])
        / df["pre_exp_purchases"].var()
    )
    df["converted_cuped"] = df["converted"] - theta * (
        df["pre_exp_purchases"] - df["pre_exp_purchases"].mean()
    )

    control = df[df["variant"] == "control"]["converted_cuped"]
    treatment = df[df["variant"] == "treatment"]["converted_cuped"]
    t_stat, p_val = stats.ttest_ind(control, treatment, equal_var=False)

    context.add_output_metadata({
        "srm_p_value": float(srm_p_value),
        "srm_passed": bool(srm_p_value > 0.01),
        "cuped_p_value": float(p_val),
        "statistically_significant": bool(p_val < 0.05),
        "sample_size": len(df),
    })
