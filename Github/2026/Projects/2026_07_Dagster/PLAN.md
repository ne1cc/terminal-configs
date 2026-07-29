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

- [x] Materialize all assets in the Dagster UI and verify metadata output
- [x] Add dbt tests (`not_null`, `accepted_values`, `unique`) to staging and marts
- [x] Add a Dagster asset check for SRM — fail materialization if `srm_p_value <= SRM_ALPHA`
- [x] Add a `.gitignore` (`.venv/`, `*.duckdb`, `dbt_project/target/`, `.tmp_dagster_home_*`)
- [x] Pin dependency versions in `pyproject.toml` after confirming the working set

## Phase 2: Extend the Analytics (Week 2)

- [x] Add segment-level analysis (e.g., by `pre_exp_purchases` quartile)
- [x] Implement sequential testing (always-valid p-values) for early stopping
- [x] Add a second metric asset (e.g., revenue per user) to show multi-metric support
- [x] Compute confidence intervals and effect size (Cohen's h) alongside p-values
- [x] Log richer metadata: lift %, CI bounds, power estimate

## Phase 3: Production Patterns (Week 3)

- [x] Add a Dagster schedule (daily cron) and sensor (trigger on new data arrival)
- [x] Introduce partitions (daily `DatePartitionsDefinition`) for incremental runs
- [ ] Swap DuckDB for Postgres via `dbt-postgres` to show warehouse portability
- [x] Add `dagster deploy` config (Dockerfile, `workspace.yaml`, `dagster.yaml`)
- [x] Write integration tests using `dagster.materialize` with a temp DuckDB

## Phase 4: Portfolio Polish (Week 4)

- [ ] Record a 2-min Loom/video walkthrough of the Dagster UI lineage + metadata
- [x] Add a top-level `README.md` with architecture diagram, quickstart, and screenshot
- [x] Add CI (GitHub Actions): lint, type-check, `dagster asset materialize` smoke test
- [ ] Publish as a Dagster project template or blog post
- [ ] Tag a `v1.0` release

## Phase 5: Decision Intelligence Layer (Week 5)

- [x] Experiment config as YAML with Pydantic validation (`experiment.yaml`)
- [x] Metric registry for declarative metric definitions
- [x] Decision engine: deterministic ship/hold/kill with auditable reasoning
- [x] Guardrail framework: one-sided non-inferiority test + blocking asset check
- [x] Revenue impact projection: annualized $ delta with CI and payback period
- [x] Automated experiment report (Jinja2 markdown template)
- [x] Unit tests for decision engine and guardrails (14 new tests)
- [x] CI smoke test updated to include decision assets

## Phase 6: Multi-Experiment Platform (Week 6)

- [x] Experiment registry: auto-discovers YAML configs in `experiments/` directory
- [x] `list_experiments()` / `get_experiment(name)` API for programmatic access
- [x] Per-experiment notifications config (Slack channel, webhook URL)
- [x] Second example experiment (`onboarding_flow_v2.yaml`) proving multi-experiment support

## Phase 7: Alerting & Notifications (Week 6)

- [x] Slack webhook integration (`notifications.py`) with formatted decision alerts
- [x] Fires on SHIP/KILL verdicts only (configurable via `should_alert`)
- [x] Integrated into `experiment_decision` asset — zero-config when webhook URL is set
- [x] Alert payload includes verdict, confidence, reasons, and revenue projection

## Phase 8: Thompson Sampling Bandits (Week 6)

- [x] Beta-Bernoulli Thompson sampling implementation (`bandits.py`)
- [x] Fixed-split comparison baseline for regret analysis
- [x] Dagster asset (`thompson_sampling_simulation`) with convergence metadata
- [x] Unit tests: best-arm identification, convergence, regret reduction, determinism

## Phase 9: Infrastructure as Code (Week 6)

- [x] Terraform: ECS Fargate cluster, ECR, RDS Postgres, Secrets Manager, CloudWatch
- [x] Security groups with least-privilege (RDS only accessible from ECS tasks)
- [x] GitHub Actions deploy workflow (OIDC auth, tag-triggered, image validation)
- [x] Environment-aware (staging vs production) with deletion protection

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
