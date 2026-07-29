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
raw_experiment_events  ->  stg_experiment_users  ->  fct_experiment_users  ->  ab_test_summary_metrics
     (python)                   (dbt view)               (dbt table)               (python)
```

## Documentation

| Doc | Purpose |
|-----|---------|
| [Architecture](./architecture.md) | System design, asset graph, data flow, and key decisions |
| [Setup](./setup.md) | Environment installation and configuration |
| [Assets](./assets.md) | Reference for every asset and module-level constants |
| [dbt Models](./dbt-models.md) | Model documentation and source definitions |
| [Statistics](./statistics.md) | SRM check, CUPED methodology, and data generation parameters |
| [Operations](./operations.md) | Running, scheduling, and troubleshooting |

## Tech Stack

- **Dagster** — asset-based orchestration and observability
- **dbt (dbt-duckdb)** — SQL transformations with manifest-driven lineage
- **DuckDB** — embedded analytical database (zero-config)
- **SciPy / NumPy / Pandas** — statistical testing and data manipulation

## Code Quality

- Local RNG generators (no global state mutation)
- Context-managed DuckDB connections (leak-proof)
- Read-only connections for analytics queries
- Named constants for statistical thresholds (`SRM_ALPHA`, `SIGNIFICANCE_ALPHA`)
- Single source of truth for group identity (`is_treatment` from dbt)
- Explicit DataFrame registration (no implicit replacement scans)
