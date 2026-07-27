# Setup

## Prerequisites

- Python 3.10+
- pip (or uv / poetry)

## Installation

```bash
# Clone the repository
git clone <repo-url> && cd 2026_07_Dagster

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate

# Install the project and all dependencies
pip install -e .
```

## Dependencies

Installed via `pyproject.toml`:

| Package | Role |
|---------|------|
| `dagster` | Core orchestration framework |
| `dagster-webserver` | Local development UI |
| `dagster-dbt` | dbt ↔ Dagster asset integration |
| `dbt-duckdb` | dbt adapter for DuckDB |
| `duckdb` | Embedded analytical database |
| `pandas` | DataFrames for ingestion/analysis |
| `numpy` | Random variate generation |
| `scipy` | Statistical tests (chi-square, t-test) |

## dbt Configuration

The dbt profile lives at `dbt_project/profiles.yml` and defaults to a local `dev.duckdb` file. Override the path with an environment variable if needed:

```bash
export DBT_DUCKDB_PATH=/tmp/my_experiment.duckdb
```

## Verifying the Install

```bash
# Confirm Dagster can load the code location
dagster code-server list

# Confirm dbt can parse the project
cd dbt_project && dbt parse
```

## Launching the Dev Server

```bash
dagster dev
```

This starts:
- Dagster webserver at http://localhost:3000
- A local code server that hot-reloads on file changes
