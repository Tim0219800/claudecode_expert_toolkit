# Changelog

All notable changes to Claude Code Premium will be documented in this file.

## [2.0.0] - 2025-12-27

### Added
- **Enhanced Status Line** - Multi-line premium display with:
  - Session timing with seconds precision
  - Weekly statistics tracking (sessions, cost, time, tokens)
  - Estimated time until context reset
  - Tokens per minute (tpm) rate
  - Persistent weekly data storage

### Changed
- Status line now shows 5 lines of information
- Context bar extended to 15 segments
- Added emojis for better visual scanning
- Improved color coding

### Technical
- Added `weekly_stats.json` for persistent tracking
- Session deduplication to prevent double counting
- Cross-platform weekly stats support (bash + PowerShell)

---

## [1.0.0] - 2025-12-26

### Added
- **Status Line** - Real-time status bar with:
  - Project path
  - Git branch with dirty indicator
  - Model name (color-coded)
  - Session duration
  - Context usage bar (visual + percentage)
  - Cost tracking with hourly rate
  - Lines modified counter

- **15 Skills**:
  - `/history` - Session history viewer
  - `/stats` - Session dashboard
  - `/quick-commit` - Smart auto-commit
  - `/explain` - Code explainer
  - `/fix` - Auto-fix errors
  - `/review` - Code review
  - `/project-init` - Project setup
  - `/todo` - Project todo list
  - `/notes` - Quick notes
  - `/test` - Test runner + fixer
  - `/docs` - Documentation generator
  - `/refactor` - Refactoring suggestions
  - `/perf` - Performance analysis
  - `/deploy` - Deployment automation
  - `/budget` - Cost tracking
  - `/update` - Plugin updater

- **Auto-Permissions** for common operations
- **Session Saving** with automatic backups
- **Daily Summaries** in Markdown format
- **Cross-platform** support (Windows, Linux, macOS)

### Installation
- PowerShell installer for Windows
- Bash installer for Linux/macOS
- Remote one-liner installers

---

## Future Plans

- [ ] Custom themes for status line
- [ ] Plugin marketplace integration
- [ ] Team sharing features
- [ ] VS Code extension sync
- [ ] API usage analytics
