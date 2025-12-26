# Claude Code Premium Plugin

A beautiful, feature-rich plugin for [Claude Code](https://claude.ai/code) that adds a premium status bar, powerful skills, session tracking, and auto-permissions.

![Status Line Preview](docs/preview.png)

## Features

### Real-time Status Bar

```
~/project | main* | Opus | 12m | ████░░░░░░ 35% | $2.45 ($4.20/h) | +156/-23
```

- **Project path** - Current working directory
- **Git branch** - With dirty indicator (*)
- **Model** - Color-coded (Opus=magenta, Sonnet=cyan, Haiku=green)
- **Duration** - Session time
- **Context bar** - Visual progress with color coding (green→yellow→red)
- **Cost** - Session cost with hourly rate
- **Lines changed** - Code modifications (+added/-removed)

### 14 Powerful Skills

| Skill | Description |
|-------|-------------|
| `/history` | View all past sessions with costs |
| `/stats` | Detailed session dashboard |
| `/quick-commit` | Auto-commit with smart messages |
| `/explain` | Deep code explanation |
| `/fix` | Auto-fix lint/type errors |
| `/review` | Professional code review |
| `/project-init` | Setup CLAUDE.md and config |
| `/todo` | Persistent project todo list |
| `/notes` | Quick notes per project |
| `/test` | Run tests and fix failures |
| `/docs` | Generate documentation |
| `/refactor` | Smart refactoring suggestions |
| `/perf` | Performance analysis |
| `/deploy` | Automated deployment |
| `/budget` | Cost tracking and alerts |

### Auto-Permissions

No more confirmation prompts for common operations:
- File read/write/edit
- Git commands
- npm/yarn/pnpm
- Python/pip
- TypeScript/ESLint/Prettier
- Test frameworks

### Session History

Automatic session saving with:
- Transcript backups
- Daily summaries
- Cost tracking
- Searchable history

---

## Installation

### Windows (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/Tim0219800/claudecode_expert_toolkit.git
cd claudecode_expert_toolkit

# Run installer
.\install.ps1
```

### Linux / macOS

```bash
# Clone the repository
git clone https://github.com/Tim0219800/claudecode_expert_toolkit.git
cd claudecode_expert_toolkit

# Make installer executable and run
chmod +x install.sh
./install.sh
```

### One-liner Install

**Windows:**
```powershell
iwr -useb https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.sh | bash
```

---

## Usage

After installation, **restart Claude Code**:

```bash
claude
```

The status bar will appear automatically at the bottom of your terminal.

### Using Skills

Just type the skill name:

```
/history          # View session history
/quick-commit     # Commit with auto-message
/fix              # Fix all lint errors
/review           # Code review current changes
```

---

## Configuration

Settings are stored in `~/.claude/settings.json`.

### Customize Permissions

Add or remove auto-allowed commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)",
      "Bash(kubectl *)"
    ]
  }
}
```

### Disable Status Line

```json
{
  "statusLine": null
}
```

### Custom Hooks

Add hooks for events:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "echo 'Tool about to run'"
      }
    ]
  }
}
```

---

## Updating

### Windows

```powershell
cd claudecode_expert_toolkit
git pull
.\install.ps1 -Update
```

### Linux/macOS

```bash
cd claudecode_expert_toolkit
git pull
./install.sh --update
```

---

## Uninstalling

### Windows

```powershell
.\install.ps1 -Uninstall
```

### Linux/macOS

```bash
./install.sh --uninstall
```

---

## File Structure

```
~/.claude/
├── settings.json          # Configuration
├── statusline.ps1/.sh     # Status bar script
├── commands/              # Skills
│   ├── history.md
│   ├── stats.md
│   ├── quick-commit.md
│   └── ...
├── hooks/                 # Event hooks
│   └── save-session.ps1/.sh
└── history/               # Session data
    ├── sessions-index.json
    ├── daily/
    │   └── 2025-01-15.md
    └── *.jsonl            # Transcripts
```

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Adding a New Skill

1. Create `src/commands/your-skill.md`
2. Add YAML frontmatter with description
3. Write instructions for Claude
4. Run installer to deploy

---

## License

MIT License - see [LICENSE](LICENSE)

---

## Credits

Created with Claude Code by the community.

---

## Support

- [Report Issues](https://github.com/Tim0219800/claudecode_expert_toolkit/issues)
- [Discussions](https://github.com/Tim0219800/claudecode_expert_toolkit/discussions)
