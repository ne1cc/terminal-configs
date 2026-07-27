# Repository Map

## Top Level

| Path | Purpose |
|------|---------|
| `ab_testing_dagster/` | Python package — all Dagster assets, checks, and stats |
| `dbt_project/` | dbt project — SQL models, schema tests, profiles |
| `tests/` | pytest suite (unit + integration) |
| `docs/` | Project documentation |
| `.github/workflows/` | CI (GitHub Actions) |
| `pyproject.toml` | Dependencies, packaging, pytest config |
| `Dockerfile` | Container deployment |
| `workspace.yaml` | Dagster workspace (code location) |
| `dagster.yaml` | Dagster instance storage config |
| `PLAN.md` | Phase-based roadmap with checkboxes |
| `README.md` | Project overview and quickstart |

## `ab_testing_dagster/`

| File | Responsibility | Depends on | Depended on by |
|------|---------------|------------|----------------|
| `assets.py` | Ingestion asset (partitioned), dbt assets, summary metrics, SRM check, schedule, sensor | `stats_utils.py`, dbt_project | `definitions.py`, `analytics.py` |
| `analytics.py` | Revenue, segment, sequential metrics + their SRM checks | `stats_utils.py`, `assets.py` (constants) | `definitions.py` |
| `stats_utils.py` | Pure statistical functions (no Dagster imports) | numpy, scipy, pandas | `assets.py`, `analytics.py`, `tests/` |
| `definitions.py` | Dagster Definitions entrypoint — wires assets, schedule, sensor, resources | `assets.py`, `analytics.py` | Dagster runtime |

## `dbt_project/models/`

| File | Materialization | Tests |
|------|-----------------|-------|
| `staging/_sources.yml` | — | Declares `stg_raw_events` source with Dagster asset key |
| `staging/stg_experiment_users.sql` | view | not_null, unique, accepted_values |
| `marts/fct_experiment_users.sql` | table | not_null, unique, accepted_values, is_treatment |

## `tests/`

| File | Coverage |
|------|----------|
| `test_stats_utils.py` | 19 unit tests: SRM, CUPED, Welch, CI, Cohen's h/d, power, mSPRT |
| `test_pipeline.py` | 7 integration tests: partitioned ingestion, revenue/segment/sequential assets |

## `docs/`

| File | Audience |
|------|----------|
| `README.md` | Overview + quickstart |
| `GUIDE.md` | Beginner walkthrough (line-by-line) |
| `architecture.md` | System design, data flow, decisions |
| `statistics.md` | Mathematical foundations |
| `assets.md` | Asset reference |
| `dbt-models.md` | SQL model documentation |
| `setup.md` | Installation guide |
| `operations.md` | Running and troubleshooting |
| `current-status.md` | Resume point for next session |
