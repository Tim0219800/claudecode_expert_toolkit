---
description: Set and monitor session budget alerts
---

# Budget Monitor

Track and alert on Claude Code usage costs.

## Commands:
- `/budget` - Show current session cost and history
- `/budget set $50` - Set budget alert threshold
- `/budget daily` - Show daily spending summary
- `/budget weekly` - Show weekly spending summary

## Features:

### Current Session:
```
Current Session: $4.52 ($3.20/hour)
Daily Total: $12.45
Weekly Total: $67.80
Monthly Total: $234.50
```

### Budget Alert:
When approaching budget threshold:
```
⚠️ BUDGET ALERT
You've used $45.00 of your $50.00 budget (90%)
Consider wrapping up or increasing budget.
```

### History:
Read from `~/.claude/history/sessions-index.json` and aggregate:
- Cost per day
- Cost per project
- Average session cost
- Trend analysis

### Save Settings:
Store budget in `.claude/budget.json`:
```json
{
  "dailyLimit": 50,
  "weeklyLimit": 200,
  "alertAt": 0.8
}
```
