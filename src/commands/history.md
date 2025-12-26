---
description: Display session history with costs and statistics
---

# Session History

Read the session index file at `~/.claude/history/sessions-index.json` and display a summary table.

For each session show:
- Date and time
- Project name
- Model used
- Cost ($)
- Duration (minutes)
- Lines modified (+/-)

Format as a readable Markdown table.

If user asks for details of a specific session, read the corresponding transcript file in `~/.claude/history/`.

If user asks for a daily summary, read files in `~/.claude/history/daily/`.

Calculate totals:
- Total cost for the period
- Total time spent
- Number of sessions
