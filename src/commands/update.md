---
description: Update Claude Code Premium plugin to latest version
---

# Update Plugin

Check for and install updates to the Claude Code Premium plugin.

## Steps:

1. **Check current version**:
   - Read `~/.claude/.plugin-version`
   - Display current version and install date

2. **Check for updates**:
   - Fetch latest release from GitHub API
   - Compare versions

3. **If update available**:
   - Show changelog/what's new
   - Ask user to confirm
   - Download and run installer
   - Restart prompt

4. **Display status**:
   ```
   Current version: 1.0.0
   Latest version:  1.1.0

   What's new in 1.1.0:
   - New /deploy skill
   - Improved status line performance
   - Bug fixes

   Run update? (y/n)
   ```

## Commands:
- `/update` - Check and install updates
- `/update check` - Just check, don't install
- `/update force` - Reinstall current version
