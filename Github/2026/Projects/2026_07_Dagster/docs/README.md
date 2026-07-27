# A/B Testing Pipeline — Dagster + dbt + DuckDB

A production-grade experimentation pipeline that generates synthetic telemetry, transforms it with dbt, and runs CUPED-adjusted hypothesis tests — all orchestrated as declarative data assets in Dagster.

## Quick Start

```bash
pip install -e .
dagster dev
```

Open http://localhost:3000 and click **Materialize All**.

## Pipeline Lineage

```
raw_experiment_events  →  stg_experiment_users  →  fct_experiment_users  →  ab_test_summary_metrics
     (python)                  (dbt view)              (dbt table)              (python)
```

## Documentation

| Doc | Purpose |
|-----|---------|
| [Architecture](./architecture.md) | System design, asset graph, and data flow |
| [Setup](./setup.md) | Environment installation and configuration |
| [Assets](./assets.md) | Reference for every asset in the pipeline |
| [dbt Models](./dbt-models.md) | Model documentation and source definitions |
| [Statistics](./statistics.md) | SRM check and CUPED methodology |
| [Operations](./operations.md) | Running, scheduling, and troubleshooting |

## Tech Stack

- **Dagster** — asset-based orchestration and observability
- **dbt (dbt-duckdb)** — SQL transformations with manifest-driven lineage
- **DuckDB** — embedded analytical database (zero-config)
- **SciPy / NumPy / Pandas** — statistical testing and data manipulation
