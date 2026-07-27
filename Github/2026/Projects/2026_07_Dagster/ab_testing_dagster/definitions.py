from dagster import Definitions, load_assets_from_modules
from dagster_dbt import DbtCliResource

from . import assets
from .assets import dbt_project

defs = Definitions(
    assets=load_assets_from_modules([assets]),
    resources={
        "dbt": DbtCliResource(project_dir=dbt_project),
    },
)
