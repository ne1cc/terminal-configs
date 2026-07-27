# Operations

## Running the Pipeline

### Development (interactive)

```bash
dagster dev
```

Opens the Dagster UI at http://localhost:3000. Use **Materialize All** to run the full pipeline, or select individual assets to materialize incrementally.

### Programmatic (CLI)

```bash
# Materialize all assets
dagster asset materialize --select "*" -m ab_testing_dagster.definitions

# Materialize a single asset
dagster asset materialize --select ab_test_summary_metrics -m ab_testing_dagster.definitions
```

### Python API

```python
from dagster import materialize
from ab_testing_dagster.assets import raw_experiment_events, ab_test_summary_metrics

result = materialize([raw_experiment_events, ab_test_summary_metrics])
```

---

## Scheduling (Production)

To run on a cron schedule, add a `ScheduleDefinition` in `definitions.py`:

```python
from dagster import ScheduleDefinition, define_asset_job

daily_job = define_asset_job("daily_ab_pipeline", selection="*")
daily_schedule = ScheduleDefinition(job=daily_job, cron_schedule="0 6 * * *")

defs = Definitions(
    assets=...,
    schedules=[daily_schedule],
)
```

Then deploy with `dagster deploy` or run the daemon locally:

```bash
dagster-daemon run
```

---

## Viewing Results

1. Open http://localhost:3000
2. Navigate to **Assets** → select `ab_test_summary_metrics`
3. Click the latest materialization event
4. Inspect **Output Metadata** for SRM and CUPED statistics

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `manifest.json not found` | dbt project not parsed yet | Run `cd dbt_project && dbt parse` |
| `Table stg_raw_events does not exist` | Ingestion asset not materialized | Materialize `raw_experiment_events` first |
| `SRM check failed` | Randomization bug (unlikely with seed=42) | Verify no filtering before variant assignment |
| Port 3000 in use | Another Dagster instance running | `dagster dev -p 3001` |
| DuckDB lock error | Concurrent connections | Ensure only one process writes at a time |

---

## Cleaning Up

```bash
# Remove the DuckDB database
rm dbt_project/dev.duckdb

# Remove dbt build artifacts
rm -rf dbt_project/target/

# Remove Dagster run storage
rm -rf ~/.dagster/
```

---

## Project Structure

```
.
├── ab_testing_dagster/
│   ├── __init__.py
│   ├── assets.py            # All asset definitions
│   └── definitions.py       # Dagster Definitions entrypoint
├── dbt_project/
│   ├── dbt_project.yml      # dbt project config
│   ├── profiles.yml         # DuckDB connection profile
│   └── models/
│       ├── staging/
│       │   ├── _sources.yml
│       │   └── stg_experiment_users.sql
│       └── marts/
│           └── fct_experiment_users.sql
├── docs/                    # This documentation
└── pyproject.toml           # Python packaging & dependencies
```
