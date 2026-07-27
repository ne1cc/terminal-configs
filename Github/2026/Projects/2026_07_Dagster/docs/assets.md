# Asset Reference

All assets are defined in `ab_testing_dagster/assets.py` and registered via `ab_testing_dagster/definitions.py`.

---

## `raw_experiment_events`

| Property | Value |
|----------|-------|
| Group | `ingestion` |
| Compute kind | `python` |
| Output | Path to `dev.duckdb` (string) |
| Side effect | Creates/replaces DuckDB table `stg_raw_events` |

### Behavior

1. Seeds NumPy RNG with `42` for reproducibility.
2. Generates 50,000 synthetic users:
   - `user_id` — sequential integer
   - `variant` — 50/50 split between `control` and `treatment`
   - `pre_exp_purchases` — Poisson(λ=1.2) covariate
   - `converted` — Bernoulli; base rate 12%, treatment lift +3.5pp
3. Writes the DataFrame to DuckDB via `CREATE OR REPLACE TABLE`.

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

1. Reads `fct_experiment_users` from DuckDB.
2. **SRM check** — chi-square test on variant counts (threshold: p > 0.01).
3. **CUPED adjustment** — computes θ = Cov(Y, X) / Var(X), adjusts conversion metric.
4. **Welch's t-test** — two-sample, unequal variance test on CUPED-adjusted metric.
5. Logs metadata to Dagster UI:
   - `srm_p_value`, `srm_passed`
   - `cuped_p_value`, `statistically_significant`
   - `sample_size`

### Upstream Dependencies

Explicit `deps=["fct_experiment_users"]`.
