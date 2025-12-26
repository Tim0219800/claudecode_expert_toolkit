#!/bin/bash
# ============================================================================
# Claude Code Premium Plugin Installer for Linux/macOS
# ============================================================================

set -e

# === CONFIGURATION ===
PLUGIN_NAME="Claude Code Premium"
VERSION="1.0.0"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/.backup"
REPO_URL="https://github.com/Tim0219800/claudecode_expert_toolkit"

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === FUNCTIONS ===

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Claude Code Premium Plugin Installer            ║${NC}"
    echo -e "${CYAN}║                     Version ${VERSION}                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

success() { echo -e "  ${GREEN}✓${NC} $1"; }
info() { echo -e "  ${CYAN}ℹ${NC} $1"; }
warning() { echo -e "  ${YELLOW}⚠${NC} $1"; }
error() { echo -e "  ${RED}✗${NC} $1"; }

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        warning "jq is not installed. Installing..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command -v brew &> /dev/null; then
            brew install jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        else
            error "Please install jq manually: https://stedolan.github.io/jq/download/"
            exit 1
        fi
    fi
}

check_claude() {
    if ! command -v claude &> /dev/null; then
        warning "Claude Code CLI not found in PATH"
        info "Please install Claude Code first: npm install -g @anthropic-ai/claude-code"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

backup_config() {
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        mkdir -p "$BACKUP_DIR"
        cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/settings_$timestamp.json"
        info "Backed up existing settings.json"
    fi
}

install_plugin() {
    info "Installing $PLUGIN_NAME..."

    # Create directories
    mkdir -p "$CLAUDE_DIR/commands"
    mkdir -p "$CLAUDE_DIR/hooks"
    mkdir -p "$CLAUDE_DIR/history/daily"
    success "Created directory structure"

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Copy status line
    if [ -f "$SCRIPT_DIR/src/statusline.sh" ]; then
        cp "$SCRIPT_DIR/src/statusline.sh" "$CLAUDE_DIR/statusline.sh"
        chmod +x "$CLAUDE_DIR/statusline.sh"
        success "Installed status line"
    fi

    # Copy hooks
    if [ -d "$SCRIPT_DIR/src/hooks" ]; then
        cp "$SCRIPT_DIR/src/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
        chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
        success "Installed hooks"
    fi

    # Copy commands (skills)
    if [ -d "$SCRIPT_DIR/src/commands" ]; then
        cp "$SCRIPT_DIR/src/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
        skill_count=$(ls -1 "$CLAUDE_DIR/commands/"*.md 2>/dev/null | wc -l)
        success "Installed $skill_count skills"
    fi

    # Create settings.json
    cat > "$CLAUDE_DIR/settings.json" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  },
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "~/.claude/hooks/save-session.sh"
      }
    ]
  },
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep", "LS",
      "NotebookEdit", "TodoRead", "TodoWrite", "WebFetch", "WebSearch",
      "Bash(git *)", "Bash(npm *)", "Bash(npx *)", "Bash(node *)",
      "Bash(python *)", "Bash(pip *)", "Bash(pnpm *)", "Bash(yarn *)",
      "Bash(cargo *)", "Bash(go *)", "Bash(mkdir *)", "Bash(ls *)",
      "Bash(cd *)", "Bash(cat *)", "Bash(echo *)", "Bash(pwd)",
      "Bash(which *)", "Bash(code *)", "Bash(tsc *)",
      "Bash(eslint *)", "Bash(prettier *)", "Bash(jest *)",
      "Bash(vitest *)", "Bash(pytest *)"
    ],
    "deny": []
  }
}
EOF
    success "Configured settings.json"

    # Save version info
    cat > "$CLAUDE_DIR/.plugin-version" << EOF
{
  "version": "$VERSION",
  "installedAt": "$(date -Iseconds)",
  "platform": "$(uname -s | tr '[:upper:]' '[:lower:]')"
}
EOF
}

uninstall_plugin() {
    info "Uninstalling $PLUGIN_NAME..."

    rm -f "$CLAUDE_DIR/statusline.sh"
    rm -f "$CLAUDE_DIR/.plugin-version"
    rm -f "$CLAUDE_DIR/commands/"*.md 2>/dev/null
    rm -f "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null

    success "Plugin uninstalled"
    info "Your history and settings.json were preserved"
    info "To completely remove, delete: $CLAUDE_DIR"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --install     Install the plugin (default)"
    echo "  --uninstall   Remove the plugin"
    echo "  --update      Update to latest version"
    echo "  --help        Show this help"
}

# === MAIN ===

ACTION="install"

while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall|-u)
            ACTION="uninstall"
            shift
            ;;
        --update)
            ACTION="update"
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

print_header
check_dependencies
check_claude

case $ACTION in
    install|update)
        backup_config
        install_plugin

        echo ""
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              Installation Complete!                       ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        info "Restart Claude Code to activate the plugin:"
        echo -e "    ${YELLOW}claude${NC}"
        echo ""
        info "Available skills:"
        for skill in "$CLAUDE_DIR/commands/"*.md; do
            [ -f "$skill" ] && echo -e "    ${CYAN}/$(basename "$skill" .md)${NC}"
        done
        echo ""
        info "To update later, run:"
        echo -e "    ${YELLOW}./install.sh --update${NC}"
        echo ""
        ;;
    uninstall)
        backup_config
        uninstall_plugin
        ;;
esac
