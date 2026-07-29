from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Literal

from .stats_utils import cohens_h, cohens_d


@dataclass(frozen=True)
class MetricSpec:
    name: str
    column: str
    metric_type: Literal["binary", "continuous"]
    direction: Literal["increase", "decrease"]
    effect_size_fn: Callable
    cuped_covariate: str | None = "pre_exp_purchases"


METRIC_REGISTRY: dict[str, MetricSpec] = {
    "conversion_rate": MetricSpec(
        name="conversion_rate",
        column="converted",
        metric_type="binary",
        direction="increase",
        effect_size_fn=cohens_h,
    ),
    "revenue_per_user": MetricSpec(
        name="revenue_per_user",
        column="revenue",
        metric_type="continuous",
        direction="increase",
        effect_size_fn=cohens_d,
    ),
}


def get_metric(name: str) -> MetricSpec:
    if name not in METRIC_REGISTRY:
        raise KeyError(f"Unknown metric '{name}'. Available: {list(METRIC_REGISTRY)}")
    return METRIC_REGISTRY[name]
