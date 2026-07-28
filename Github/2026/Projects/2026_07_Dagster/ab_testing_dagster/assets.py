import numpy as np
import pandas as pd
import scipy.stats as stats
from datetime import datetime, timedelta
from pathlib import Path

from dagster import (
    asset,
    AssetExecutionContext,
    AssetCheckResult,
    asset_check,
    DailyPartitionsDefinition,
    ScheduleDefinition,
    SensorDefinition,
    sensor,
    RunRequest,
    define_asset_job,
)
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject

from .stats_utils import srm_p_value, cuped_adjust, welch_test, mean_diff_ci, cohens_h, posthoc_power
from .db import get_connection, read_sql, write_dataframe, DUCKDB_PATH, WAREHOUSE

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
DB_PATH = DUCKDB_PATH
SRM_ALPHA = 0.01
SIGNIFICANCE_ALPHA = 0.05
EXPERIMENT_DAYS = 28

EXPERIMENT_START = datetime(2026, 7, 1)

daily_partitions = DailyPartitionsDefinition(
    start_date=EXPERIMENT_START,
    end_date=EXPERIMENT_START + timedelta(days=EXPERIMENT_DAYS),
)

dbt_project = DbtProject(project_dir=DBT_PROJECT_DIR)
dbt_project.prepare_if_dev()


@asset(
    group_name="ingestion",
    compute_kind="python",
    partitions_def=daily_partitions,
)
def raw_experiment_events(context: AssetExecutionContext):
    """Generates synthetic user telemetry for a single experiment day."""
    partition_date = datetime.strptime(context.partition_key, "%Y-%m-%d")
    day_number = (partition_date - EXPERIMENT_START).days + 1

    rng = np.random.default_rng(42 + day_number)
    n_users = 50000 // EXPERIMENT_DAYS

    users = pd.DataFrame({
        "user_id": np.arange(1, n_users + 1) + (day_number - 1) * n_users,
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

    users["arrived_at"] = day_number

    with get_connection() as con:
        if WAREHOUSE == "postgres":
            cur = con.cursor()
            cur.execute(
                "CREATE TABLE IF NOT EXISTS stg_raw_events ("
                "user_id INTEGER, variant VARCHAR, pre_exp_purchases INTEGER,"
                "converted INTEGER, revenue DOUBLE PRECISION, arrived_at INTEGER)"
            )
            cur.execute("DELETE FROM stg_raw_events WHERE arrived_at = %s", (day_number,))
            cur.close()
        else:
            con.execute(
                "CREATE TABLE IF NOT EXISTS stg_raw_events ("
                "user_id INTEGER, variant VARCHAR, pre_exp_purchases INTEGER,"
                "converted INTEGER, revenue DOUBLE, arrived_at INTEGER)"
            )
            con.execute("DELETE FROM stg_raw_events WHERE arrived_at = ?", [day_number])
        write_dataframe(con, users, "stg_raw_events")


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
    with get_connection(read_only=True) as con:
        df = read_sql(
            con,
            "SELECT variant, converted, pre_exp_purchases, is_treatment"
            " FROM fct_experiment_users",
        )

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
    with get_connection(read_only=True) as con:
        df = read_sql(con, "SELECT variant FROM fct_experiment_users")

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


daily_analytics_job = define_asset_job(
    "daily_analytics",
    selection=["ab_test_summary_metrics", "ab_test_revenue_metrics", "ab_test_segment_metrics", "ab_test_sequential_metrics"],
)

daily_schedule = ScheduleDefinition(
    job=daily_analytics_job,
    cron_schedule="0 6 * * *",
)


@sensor(job=daily_analytics_job, minimum_interval_seconds=300)
def new_data_sensor(context):
    """Triggers analytics when the DuckDB file is modified (simulating new data arrival)."""
    if not DB_PATH.exists():
        return

    cursor = context.cursor or "0"
    last_mtime = float(cursor)
    current_mtime = DB_PATH.stat().st_mtime

    if current_mtime > last_mtime:
        context.update_cursor(str(current_mtime))
        yield RunRequest(run_key=f"mtime_{int(current_mtime)}")
