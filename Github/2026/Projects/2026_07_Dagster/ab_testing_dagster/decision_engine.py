from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal


@dataclass(frozen=True)
class Decision:
    verdict: Literal["ship", "hold", "kill"]
    confidence_level: float
    reasons: list[str] = field(default_factory=list)


def decide(
    p_value: float,
    ci_lower: float,
    ci_upper: float,
    power: float,
    alpha: float,
    target_power: float,
    guardrail_passed: bool,
    sequential_can_stop: bool = False,
) -> Decision:
    reasons: list[str] = []

    if p_value < alpha and ci_upper < 0:
        reasons.append(f"Statistically significant negative effect (p={p_value:.4f}, CI upper={ci_upper:.4f})")
        return Decision(verdict="kill", confidence_level=1.0 - p_value, reasons=reasons)

    if p_value >= alpha:
        reasons.append(f"Not statistically significant (p={p_value:.4f} >= {alpha})")
        return Decision(verdict="hold", confidence_level=1.0 - p_value, reasons=reasons)

    if ci_lower <= 0:
        reasons.append(f"Confidence interval includes zero (CI=[{ci_lower:.4f}, {ci_upper:.4f}])")
        return Decision(verdict="hold", confidence_level=1.0 - p_value, reasons=reasons)

    if power < target_power:
        reasons.append(f"Underpowered (power={power:.3f} < {target_power})")
        return Decision(verdict="hold", confidence_level=1.0 - p_value, reasons=reasons)

    if not guardrail_passed:
        reasons.append("Guardrail metric violated")
        return Decision(verdict="hold", confidence_level=1.0 - p_value, reasons=reasons)

    reasons.append(f"Significant positive effect (p={p_value:.4f}, CI=[{ci_lower:.4f}, {ci_upper:.4f}])")
    reasons.append(f"Adequately powered (power={power:.3f} >= {target_power})")
    reasons.append("All guardrails passed")
    if sequential_can_stop:
        reasons.append("Sequential test confirms early stopping validity")

    return Decision(verdict="ship", confidence_level=1.0 - p_value, reasons=reasons)
