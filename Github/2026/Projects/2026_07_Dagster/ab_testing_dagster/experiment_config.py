from __future__ import annotations

from pathlib import Path

import yaml
from pydantic import BaseModel, Field

PROJECT_ROOT = Path(__file__).joinpath("..", "..").resolve()
EXPERIMENTS_DIR = PROJECT_ROOT / "experiments"
LEGACY_CONFIG_PATH = PROJECT_ROOT / "experiment.yaml"


class SequentialConfig(BaseModel):
    tau: float = 0.01
    alpha: float = 0.05


class RevenueConfig(BaseModel):
    daily_users: int = 50000
    implementation_cost: float = 50000.0


class NotificationsConfig(BaseModel):
    slack_channel: str | None = None
    slack_webhook_url: str | None = None


class ExperimentConfig(BaseModel):
    name: str = "checkout_redesign_2026"
    owner: str = "growth-team"
    start_date: str = "2026-07-01"
    duration_days: int = 28
    mde: float = 0.035
    alpha: float = 0.05
    target_power: float = 0.80
    srm_alpha: float = 0.01
    primary_metric: str = "conversion_rate"
    guardrail_metrics: list[str] = Field(default_factory=lambda: ["revenue_per_user"])
    guardrail_margin: float = 0.01
    segments: list[str] = Field(default_factory=lambda: ["pre_exp_purchases_quartile"])
    sequential: SequentialConfig = Field(default_factory=SequentialConfig)
    revenue: RevenueConfig = Field(default_factory=RevenueConfig)
    notifications: NotificationsConfig = Field(default_factory=NotificationsConfig)


def load_config(path: Path | None = None) -> ExperimentConfig:
    if path and path.exists():
        with open(path) as f:
            raw = yaml.safe_load(f)
        return ExperimentConfig(**raw.get("experiment", {}))
    if LEGACY_CONFIG_PATH.exists():
        with open(LEGACY_CONFIG_PATH) as f:
            raw = yaml.safe_load(f)
        return ExperimentConfig(**raw.get("experiment", {}))
    return ExperimentConfig()


def list_experiments() -> list[ExperimentConfig]:
    """Discover all experiment configs in the experiments/ directory."""
    if not EXPERIMENTS_DIR.exists():
        return [load_config()]
    configs = []
    for path in sorted(EXPERIMENTS_DIR.glob("*.yaml")):
        with open(path) as f:
            raw = yaml.safe_load(f)
        if raw and "experiment" in raw:
            configs.append(ExperimentConfig(**raw["experiment"]))
    return configs or [load_config()]


def get_experiment(name: str) -> ExperimentConfig:
    """Get a specific experiment by name."""
    for exp in list_experiments():
        if exp.name == name:
            return exp
    raise KeyError(f"Experiment '{name}' not found. Available: {[e.name for e in list_experiments()]}")


config = load_config()
