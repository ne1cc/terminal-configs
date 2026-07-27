select
    user_id,
    variant,
    pre_exp_purchases,
    converted
from {{ source('main', 'stg_raw_events') }}
