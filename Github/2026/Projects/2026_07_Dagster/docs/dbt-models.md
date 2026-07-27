# dbt Models

Project: `dbt_project/`
Adapter: `dbt-duckdb`
Profile: `dbt_project/profiles.yml`

---

## Sources

Defined in `models/staging/_sources.yml`:

| Source | Schema | Table | Description |
|--------|--------|-------|-------------|
| `main` | `main` | `stg_raw_events` | Raw synthetic telemetry written by the ingestion asset |

---

## Staging

### `stg_experiment_users`

- **Materialization:** view
- **Path:** `models/staging/stg_experiment_users.sql`
- **Purpose:** Thin selection layer over the raw source; establishes a stable contract for downstream marts.

```sql
select
    user_id,
    variant,
    pre_exp_purchases,
    converted
from {{ source('main', 'stg_raw_events') }}
```

---

## Marts

### `fct_experiment_users`

- **Materialization:** table
- **Path:** `models/marts/fct_experiment_users.sql`
- **Purpose:** Enriched fact table consumed by the analytics asset. Adds a binary `is_treatment` flag.

```sql
select
    user_id,
    variant,
    pre_exp_purchases,
    converted,
    case
        when variant = 'treatment' then 1
        else 0
    end as is_treatment
from {{ ref('stg_experiment_users') }}
```

---

## Model DAG

```
source: main.stg_raw_events
        │
        ▼
stg_experiment_users  (view)
        │
        ▼
fct_experiment_users  (table)
```

## Adding New Models

1. Create a `.sql` file under `models/staging/` or `models/marts/`.
2. Use `{{ ref('...') }}` or `{{ source('...') }}` for upstream references.
3. Run `dbt parse` to regenerate the manifest — Dagster picks up new nodes automatically on next code load.
