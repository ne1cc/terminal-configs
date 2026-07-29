select
    user_id,
    variant,
    pre_exp_purchases,
    converted,
    revenue,
    arrived_at,
    case
        when variant = 'treatment' then 1
        else 0
    end as is_treatment
from {{ ref('stg_experiment_users') }}
