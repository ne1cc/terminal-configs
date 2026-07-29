select
    user_id,
    variant,
    pre_exp_purchases,
    converted,
    revenue,
    arrived_at
from {{ source('main', 'stg_raw_events') }}
