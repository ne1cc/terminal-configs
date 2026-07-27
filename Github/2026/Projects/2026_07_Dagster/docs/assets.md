# Asset Reference

All assets are defined in `ab_testing_dagster/assets.py` and registered via `ab_testing_dagster/definitions.py`.

## Module-Level Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `DBT_PROJECT_DIR` | Resolved path to `dbt_project/` | Single source of truth for dbt location |
| `DB_PATH` | `DBT_PROJECT_DIR / "dev.duckdb"` | Shared DuckDB file path for all assets |
| `SRM_ALPHA` | `0.01` | Significance threshold for SRM chi-square test |
| `SIGNIFICANCE_ALPHA` | `0.05` | Significance threshold for hypothesis test |

---

## `raw_experiment_events`

| Property | Value |
|----------|-------|
| Group | `ingestion` |
| Compute kind | `python` |
| Output | None (side-effect only) |
| Side effect | Creates/replaces DuckDB table `stg_raw_events` |

### Behavior

1. Creates a local NumPy generator (`default_rng(42)`) for reproducibility without mutating global state.
2. Generates 50,000 synthetic users:
   - `user_id` — sequential integer
   - `variant` — 50/50 split between `control` and `treatment`
   - `pre_exp_purchases` — Poisson(lambda=1.2) covariate
   - `converted` — Bernoulli via a per-user probability vector (base 12%, treatment +3.5pp)
3. Registers the DataFrame explicitly with DuckDB and writes via `CREATE OR REPLACE TABLE`.
4. Uses a context manager to guarantee connection cleanup even on failure.

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

Automatically inferred from dbt source definitions (`stg_raw_events`).

---

## `ab_test_summary_metrics`

| Property | Value |
|----------|-------|
| Group | `analytics` |
| Compute kind | `python` |
| Output | Metadata only (no materialized table) |

### Behavior

1. Opens a **read-only** DuckDB connection (avoids unnecessary write locks).
2. Selects only required columns: `variant`, `converted`, `pre_exp_purchases`, `is_treatment`.
3. **SRM check** — chi-square test on variant counts (threshold: `SRM_ALPHA = 0.01`).
4. **CUPED adjustment** — computes theta = Cov(Y, X) / Var(X), adjusts conversion metric.
5. **Welch's t-test** — two-sample, unequal variance test on CUPED-adjusted metric.
6. Splits groups using the dbt-modeled `is_treatment` column (not raw string matching).
7. Logs metadata to Dagster UI:
   - `srm_p_value`, `srm_passed`
   - `cuped_p_value`, `statistically_significant`
   - `sample_size`

### Upstream Dependencies

Explicit `deps=["fct_experiment_users"]`.
