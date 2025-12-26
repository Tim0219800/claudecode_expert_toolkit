---
description: Quick commit with auto-generated message based on changes
---

# Quick Commit

1. Run `git status` and `git diff --staged` (or `git diff` if nothing staged)
2. Analyze the changes
3. Generate a concise, descriptive commit message in English
4. Run `git add .` then `git commit -m "message"`

Message format: type(scope): description
- feat: new feature
- fix: bug fix
- refactor: refactoring
- docs: documentation
- style: formatting
- test: tests
- chore: maintenance

Do not ask for confirmation, commit directly.
