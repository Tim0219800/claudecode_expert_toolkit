#!/bin/bash
# ============================================================================
# One-liner remote installer for Claude Code Premium
# Usage: curl -fsSL https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.sh | bash
# ============================================================================

set -e

REPO="Tim0219800/claudecode_expert_toolkit"
BRANCH="main"
TEMP_DIR="/tmp/claudecode_expert_toolkit-install"

echo ""
echo -e "\033[0;36m╔══════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;36m║     Claude Code Premium - Remote Installer                ║\033[0m"
echo -e "\033[0;36m╚══════════════════════════════════════════════════════════╝\033[0m"
echo ""

# Clean up
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Download
echo -e "  \033[0;36mDownloading from GitHub...\033[0m"
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TEMP_DIR"

# Find extracted folder
EXTRACTED=$(ls "$TEMP_DIR" | head -1)

# Run installer
echo -e "  \033[0;36mRunning installer...\033[0m"
cd "$TEMP_DIR/$EXTRACTED"
chmod +x install.sh
./install.sh

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo -e "  \033[0;32mInstallation complete!\033[0m"
echo ""
