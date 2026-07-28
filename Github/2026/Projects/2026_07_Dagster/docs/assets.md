# Asset Reference

Assets are defined in `ab_testing_dagster/assets.py` and `ab_testing_dagster/analytics.py`, registered via `ab_testing_dagster/definitions.py`.

## Module-Level Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `DBT_PROJECT_DIR` | Resolved path to `dbt_project/` | Single source of truth for dbt location |
| `DB_PATH` | `DBT_PROJECT_DIR / "dev.duckdb"` | Shared DuckDB file path for all assets |
| `SRM_ALPHA` | `0.01` | Significance threshold for SRM chi-square test |
| `SIGNIFICANCE_ALPHA` | `0.05` | Significance threshold for hypothesis tests |
| `EXPERIMENT_DAYS` | `28` | Total experiment duration |
| `EXPERIMENT_START` | `datetime(2026, 7, 1)` | First day of the experiment |
| `daily_partitions` | `DailyPartitionsDefinition` | 28 daily partitions starting at EXPERIMENT_START |
| `SEQ_ALPHA` | `0.05` | Always-valid significance level |
| `SEQ_TAU` | `0.01` | mSPRT mixing parameter (≤ MDE for useful CI) |
| `N_QUARTILES` | `4` | Number of segments for purchase-volume quartiles |

---

## `raw_experiment_events`

| Property | Value |
|----------|-------|
| Group | `ingestion` |
| Compute kind | `python` |
| Partitions | Daily (28 days, 2026-07-01 to 2026-07-28) |
| Output | None (side-effect only) |
| Side effect | INSERT into DuckDB table `stg_raw_events` |

### Behavior

1. Derives `day_number` from the partition key (1-indexed).
2. Creates a local NumPy generator (`default_rng(42 + day_number)`) for per-partition reproducibility.
3. Generates ~1,786 synthetic users for that day:
   - `user_id` — sequential, offset by `(day_number - 1) * n_users`
   - `variant` — 50/50 split between `control` and `treatment`
   - `pre_exp_purchases` — Poisson(lambda=1.2) covariate
   - `converted` — Bernoulli (base 12%, treatment +3.5pp)
   - `revenue` — zero-inflated lognormal (0 for non-converters; converters get lognormal(2.5, 0.8) × 1.15 if treatment)
   - `arrived_at` — equals `day_number`
4. Writes idempotently: `CREATE TABLE IF NOT EXISTS` → `DELETE WHERE arrived_at = ?` → `INSERT`.

### Upstream Dependencies

None (root asset).

---

## `my_dbt_assets` (dbt asset group)

| Property | Value |
|----------|-------|
| Group | `dbt` (auto-assigned) |
| Compute kind | `dbt` |
| Manifest | Auto-generated at `dbt_project/target/manifest.json` |

### Behavior

Executes `dbt build` which runs all models in dependency order:
- `stg_experiment_users` (view)
- `fct_experiment_users` (table)

Each dbt model becomes an individual Dagster asset node with full lineage.

### Upstream Dependencies

Automatically inferred from dbt source definitions (`stg_raw_events` linked via `meta.dagster.asset_key`).

---

## `ab_test_summary_metrics`

| Property | Value |
|----------|-------|
| Group | `analytics` |
| Compute kind | `python` |
| Output | Metadata only (no materialized table) |

### Behavior

1. Opens a **read-only** DuckDB connection.
2. Selects: `variant`, `converted`, `pre_exp_purchases`, `is_treatment`.
3. **SRM check** — chi-square test on variant counts (threshold: `SRM_ALPHA`).
4. **CUPED adjustment** — theta = Cov(Y, X) / Var(X), adjusts conversion metric.
5. **Welch's t-test** — two-sample, unequal variance on CUPED-adjusted metric.
6. Computes lift %, confidence interval, Cohen's h, and post-hoc power.
7. Logs metadata:
   - `srm_p_value`, `srm_passed`
   - `cuped_p_value`, `statistically_significant`
   - `sample_size`, `lift_pct`
   - `ci_lower`, `ci_upper`, `cohens_h`, `power_estimate`

### Upstream Dependencies

Explicit `deps=["fct_experiment_users"]`.

---

## `ab_test_revenue_metrics`

| Property | Value |
|----------|-------|
| Group | `analytics` |
| Compute kind | `python` |
| Output | Metadata only |
| Blocking check | `srm_check_revenue` |

### Behavior

CUPED-adjusted revenue-per-user analysis. Uses Cohen's d (continuous metric) instead of Cohen's h. Logs `revenue_p_value`, `lift_pct`, `ci_lower`, `ci_upper`, `cohens_d`, `power_estimate`, `mean_revenue_control`, `mean_revenue_treatment`.

---

## `ab_test_segment_metrics`

| Property | Value |
|----------|-------|
| Group | `analytics` |
| Compute kind | `python` |
| Output | Metadata only |
| Blocking check | `srm_check_segments` |

### Behavior

Splits users into quartiles by `pre_exp_purchases` (via `pd.qcut`). Runs per-segment Welch's t-test on conversion. Logs per-quartile: `q{N}_p_value`, `q{N}_lift_pct`, `q{N}_cohens_h`, `q{N}_n`, `q{N}_significant`.

---

## `ab_test_sequential_metrics`

| Property | Value |
|----------|-------|
| Group | `sequential` |
| Compute kind | `python` |
| Output | Metadata only |
| Blocking check | `srm_check_sequential` |

### Behavior

Gaussian-mixture mSPRT (Howard et al. 2021) over 28 daily cumulative looks. No CUPED (full-sample theta would leak future data into early looks). Logs `can_stop_early`, `earliest_stop_day`, `final_always_valid_p`, `final_ci_lower`, `final_ci_upper`, `n_looks`.

---

## Scheduling and Automation

| Component | Type | Definition |
|-----------|------|------------|
| `daily_analytics_job` | `define_asset_job` | Selects all 4 analytics/sequential assets |
| `daily_schedule` | `ScheduleDefinition` | Cron `0 6 * * *` targeting `daily_analytics_job` |
| `new_data_sensor` | `@sensor` | Polls `DB_PATH` mtime every 300s; yields `RunRequest` on change |
