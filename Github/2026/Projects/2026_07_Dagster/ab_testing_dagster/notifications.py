import json
import urllib.request
from dataclasses import dataclass


@dataclass
class AlertPayload:
    experiment_name: str
    verdict: str
    confidence_level: float
    reasons: list[str]
    annualized_revenue_usd: float | None = None
    slack_channel: str | None = None


def format_slack_message(alert: AlertPayload) -> dict:
    emoji = {"ship": ":rocket:", "kill": ":skull_and_crossbones:", "hold": ":hourglass:"}
    icon = emoji.get(alert.verdict, ":test_tube:")

    lines = [
        f"{icon} *Experiment: {alert.experiment_name}*",
        f"*Verdict: {alert.verdict.upper()}* (confidence: {alert.confidence_level:.1%})",
        "",
    ]
    for reason in alert.reasons:
        lines.append(f"  - {reason}")

    if alert.annualized_revenue_usd is not None:
        lines.append(f"\n*Projected annual impact:* ${alert.annualized_revenue_usd:,.0f}")

    return {
        "channel": alert.slack_channel or "#experiments",
        "text": "\n".join(lines),
    }


def send_slack_alert(webhook_url: str, alert: AlertPayload) -> bool:
    """Send alert via Slack incoming webhook. Returns True on success."""
    payload = format_slack_message(alert)
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status == 200
    except Exception:
        return False


def should_alert(verdict: str) -> bool:
    """Only alert on actionable verdicts, not HOLD."""
    return verdict in ("ship", "kill")
