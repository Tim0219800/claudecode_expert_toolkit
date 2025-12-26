---
description: Initialize project with CLAUDE.md and optimal configuration
---

# Project Init

Set up a new project for optimal Claude Code usage:

1. **Create CLAUDE.md** with:
   - Project description
   - Tech stack
   - Folder structure
   - Coding conventions
   - Important commands

2. **Create .claude/settings.local.json** with:
   - Project-specific permissions
   - Custom hooks if needed

3. **Update .gitignore** to include:
   ```
   .claude/
   !.claude/CLAUDE.md
   ```

4. **Detect and document**:
   - Package manager (npm/yarn/pnpm)
   - Framework (React, Vue, Next, etc.)
   - Test framework
   - Linting setup

Ask the user for project description if not obvious from existing files.
