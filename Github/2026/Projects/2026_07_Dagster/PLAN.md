# Project Plan — Next Steps

## Current State

The pipeline is fully scaffolded and running locally:
- Synthetic data ingestion (50k users, seeded RNG)
- dbt staging + mart transformations on DuckDB
- CUPED-adjusted hypothesis testing with SRM validation
- Full documentation in `docs/`
- Dagster UI live at http://localhost:3000

---

## Phase 1: Validate & Harden (This Week)

- [ ] Materialize all assets in the Dagster UI and verify metadata output
- [ ] Add dbt tests (`not_null`, `accepted_values`, `unique`) to staging and marts
- [ ] Add a Dagster asset check for SRM — fail materialization if `srm_p_value <= SRM_ALPHA`
- [ ] Add a `.gitignore` (`.venv/`, `*.duckdb`, `dbt_project/target/`, `.tmp_dagster_home_*`)
- [ ] Pin dependency versions in `pyproject.toml` after confirming the working set

## Phase 2: Extend the Analytics (Week 2)

- [ ] Add segment-level analysis (e.g., by `pre_exp_purchases` quartile)
- [ ] Implement sequential testing (always-valid p-values) for early stopping
- [ ] Add a second metric asset (e.g., revenue per user) to show multi-metric support
- [ ] Compute confidence intervals and effect size (Cohen's h) alongside p-values
- [ ] Log richer metadata: lift %, CI bounds, power estimate

## Phase 3: Production Patterns (Week 3)

- [ ] Add a Dagster schedule (daily cron) and sensor (trigger on new data arrival)
- [ ] Introduce partitions (daily `DatePartitionsDefinition`) for incremental runs
- [ ] Swap DuckDB for Postgres via `dbt-postgres` to show warehouse portability
- [ ] Add `dagster deploy` config (Dockerfile, `workspace.yaml`, `dagster.yaml`)
- [ ] Write integration tests using `dagster.materialize` with a temp DuckDB

## Phase 4: Portfolio Polish (Week 4)

- [ ] Record a 2-min Loom/video walkthrough of the Dagster UI lineage + metadata
- [ ] Add a top-level `README.md` with architecture diagram, quickstart, and screenshot
- [ ] Add CI (GitHub Actions): lint, type-check, `dagster asset materialize` smoke test
- [ ] Publish as a Dagster project template or blog post
- [ ] Tag a `v1.0` release

---

## Stretch Goals

- [ ] Multi-armed bandit simulation (Thompson sampling) as an alternative asset group
- [ ] dbt metrics layer (`dbt-metrics` / MetricFlow) for standardized KPI definitions
- [ ] Dagster+Airbyte ingestion from a real API (e.g., Google Analytics)
- [ ] Deploy to Dagster Cloud or AWS ECS with Terraform
- [ ] Add Great Expectations checks as Dagster asset checks

---

## Guiding Principles

1. Every new feature gets a corresponding doc update in `docs/`
2. Statistical rigor first — never ship a metric without SRM validation
3. Keep the one-command demo: `pip install -e . && dagster dev`
4. Prefer Dagster-native patterns (assets, checks, partitions) over custom glue code
