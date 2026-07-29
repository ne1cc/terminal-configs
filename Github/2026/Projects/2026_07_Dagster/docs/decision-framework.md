# Decision Framework

## Overview

The Decision Intelligence Layer translates statistical results into actionable business decisions. It sits downstream of all analytics assets and produces three outputs:

1. **Verdict** — ship / hold / kill with auditable reasoning
2. **Revenue impact** — annualized dollar projection with confidence interval
3. **Report** — stakeholder-ready markdown brief

## Decision Rules

The engine (`ab_testing_dagster/decision_engine.py`) applies deterministic rules:

| Verdict | Conditions |
|---------|-----------|
| **KILL** | p < alpha AND CI upper < 0 (significant negative) |
| **SHIP** | p < alpha AND CI lower > 0 AND power >= target AND all guardrails pass |
| **HOLD** | Everything else (underpowered, inconclusive, guardrail violation) |

Every decision includes a `reasons` list explaining exactly why the verdict was reached.

## Guardrail Metrics

Guardrails protect against shipping a change that improves the primary metric but harms a secondary one. The framework (`ab_testing_dagster/guardrails.py`) uses a one-sided non-inferiority test:

- H0: treatment is worse by >= margin
- Pass if: one-sided p < alpha AND CI lower > -margin

Default margin: 1% relative decline in revenue per user.

A blocking asset check (`guardrail_check`) prevents the decision asset from materializing if any guardrail fails.

## Revenue Impact Projection

Formula: `delta_rev_per_user * daily_users * 365`

- CI bounds scale identically
- Payback period = implementation_cost / daily_delta
- All parameters configurable in `experiment.yaml`

## Experiment Configuration

All decision parameters live in `experiment.yaml` (project root), validated by Pydantic:

```yaml
experiment:
  mde: 0.035
  alpha: 0.05
  target_power: 0.80
  guardrail_margin: 0.01
  revenue:
    daily_users: 50000
    implementation_cost: 50000
```

Changing config values changes decision behavior without code changes.

## Automated Report

The `experiment_report` asset renders a Jinja2 template (`templates/report.md.j2`) to `reports/latest_experiment_report.md` with sections:

- Executive Summary (verdict + reasons)
- Primary Metric (p-value, lift, CI, effect size, power)
- Revenue Impact (annualized $, CI, payback)
- Guardrail Metrics (pass/fail table)
- Sequential Analysis (early stopping status)
