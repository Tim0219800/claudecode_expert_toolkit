---
description: Display detailed current session statistics dashboard
---

# Session Statistics Dashboard

Display a comprehensive dashboard of the current session:

```
╭──────────────────────────────────────────────────────────╮
│  SESSION DASHBOARD                                        │
├──────────────────────────────────────────────────────────┤
│  Project:    [project name]                              │
│  Branch:     [git branch] ([X] modifications)            │
│  Model:      [model name]                                │
├──────────────────────────────────────────────────────────┤
│  Cost:       $X.XX ($X.XX/h)                             │
│  Duration:   Xh Xm                                       │
│  Lines:      +XXX / -XXX                                 │
│  Context:    XX% (XXXK/200K tokens)                      │
├──────────────────────────────────────────────────────────┤
│  Rate Limit: Reset in Xm at HH:MM                        │
╰──────────────────────────────────────────────────────────╯
```

Use the `/cost` command to get current cost info.
Run `git status` and `git branch` for git information.
