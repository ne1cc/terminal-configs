# Operations

## Running the Pipeline

### Development (interactive)

```bash
dagster dev
```

Opens the Dagster UI at http://localhost:3000. Use **Materialize All** to run the full pipeline, or select individual assets to materialize incrementally.

### Partitioned Materialization

The ingestion asset is partitioned by day. To backfill all partitions:

```bash
# Via UI: select raw_experiment_events → Materialize → select all partitions

# Via Python API:
python -c "
from dagster import materialize
from ab_testing_dagster.assets import raw_experiment_events, daily_partitions

for key in daily_partitions.get_partition_keys():
    materialize([raw_experiment_events], partition_key=key)
"
```

To re-materialize a single day (idempotent — safe to repeat):

```python
materialize([raw_experiment_events], partition_key="2026-07-15")
```

### Programmatic (full pipeline)

```python
import os
os.environ['PATH'] = os.path.abspath('.venv/bin') + ':' + os.environ['PATH']

from dagster import materialize
from ab_testing_dagster.assets import my_dbt_assets, ab_test_summary_metrics
from ab_testing_dagster.analytics import (
    ab_test_revenue_metrics, ab_test_segment_metrics, ab_test_sequential_metrics
)
from dagster_dbt import DbtCliResource
from ab_testing_dagster.assets import dbt_project

result = materialize(
    [my_dbt_assets, ab_test_summary_metrics, ab_test_revenue_metrics,
     ab_test_segment_metrics, ab_test_sequential_metrics],
    resources={'dbt': DbtCliResource(project_dir=dbt_project)},
)
assert result.success
```

---

## Scheduling and Sensors

The pipeline includes a registered schedule and sensor (defined in `assets.py`, registered in `definitions.py`):

| Component | Trigger | Target |
|-----------|---------|--------|
| `daily_schedule` | Cron `0 6 * * *` (06:00 UTC) | All 4 analytics assets |
| `new_data_sensor` | `dev.duckdb` mtime change (polls every 300s) | All 4 analytics assets |

To activate them in development, run the Dagster daemon:

```bash
dagster dev   # starts webserver + daemon (schedules/sensors run automatically)
```

In the UI, navigate to **Overview → Schedules** and **Overview → Sensors** to toggle them on/off.

---

## Testing

```bash
# Run all tests
pytest

# Run only unit tests
pytest tests/test_stats_utils.py

# Run only integration tests
pytest tests/test_pipeline.py

# Verbose with output
pytest -v -s
```

Tests use temporary DuckDB instances (via `tmp_path` fixture) — they never touch `dbt_project/dev.duckdb`.

---

## Docker Deployment

```bash
# Build
docker build -t ab-testing-dagster .

# Run
docker run -p 3000:3000 ab-testing-dagster
```

The container runs `dagster-webserver` with SQLite-backed run/event/schedule storage (configured in `dagster.yaml`).

For production, replace SQLite storage with Postgres in `dagster.yaml` and add `dagster-daemon` as a separate process to run schedules/sensors.

---

## Viewing Results

1. Open http://localhost:3000
2. Navigate to **Assets** → select any analytics asset
3. Click the latest materialization event
4. Inspect **Output Metadata** for statistics (p-values, CIs, lift, power)

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `manifest.json not found` | dbt project not parsed yet | Run `cd dbt_project && dbt parse` |
| `Table stg_raw_events does not exist` | Ingestion not materialized | Materialize `raw_experiment_events` (all partitions) |
| `SRM check failed` | Randomization bug | Verify no filtering before variant assignment |
| Port 3000 in use | Another Dagster instance | `dagster dev -p 3001` |
| DuckDB lock error | Concurrent write connections | Only one writer at a time; analytics uses `read_only=True` |
| `dbt` not found | venv not on PATH | Ensure `.venv/bin` is on PATH before running |
| Sequential CI always includes zero | `SEQ_TAU` too large | Must be ≤ MDE; currently 0.01 for 3.5pp effect |
| Unique test fails after re-materialization | Stale data from schema change | Delete `dev.duckdb` and re-materialize all partitions |

---

## Cleaning Up

```bash
# Remove the DuckDB database (regenerated on materialization)
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
│   ├── assets.py            # Ingestion (partitioned), dbt, summary, schedule, sensor
│   ├── analytics.py         # Revenue, segment, sequential assets + SRM checks
│   ├── stats_utils.py       # Pure statistical functions
│   └── definitions.py       # Dagster Definitions entrypoint
├── dbt_project/
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── models/
│       ├── staging/
│       │   ├── _sources.yml
│       │   ├── _stg_experiment_users.yml
│       │   └── stg_experiment_users.sql
│       └── marts/
│           ├── _fct_experiment_users.yml
│           └── fct_experiment_users.sql
├── tests/
│   ├── test_stats_utils.py  # 19 unit tests
│   └── test_pipeline.py     # 7 integration tests
├── .github/workflows/
│   └── ci.yml               # GitHub Actions: pytest + smoke test
├── docs/                    # This documentation
├── Dockerfile               # Container deployment
├── workspace.yaml           # Dagster code location
├── dagster.yaml             # Dagster instance storage
├── pyproject.toml           # Dependencies + pytest config
└── README.md                # Project overview
```
