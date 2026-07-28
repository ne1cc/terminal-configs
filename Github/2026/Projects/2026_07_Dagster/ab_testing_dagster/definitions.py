from dagster import Definitions, load_assets_from_modules
from dagster_dbt import DbtCliResource

from . import assets, analytics
from .assets import dbt_project, daily_schedule, new_data_sensor

defs = Definitions(
    assets=load_assets_from_modules([assets, analytics]),
    schedules=[daily_schedule],
    sensors=[new_data_sensor],
    resources={
        "dbt": DbtCliResource(project_dir=dbt_project),
    },
)
