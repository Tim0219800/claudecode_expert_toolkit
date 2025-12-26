<#
.SYNOPSIS
    Claude Code Premium Plugin Installer for Windows
.DESCRIPTION
    Installs the premium status line, skills, and hooks for Claude Code
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Uninstall
#>

param(
    [switch]$Uninstall,
    [switch]$Update,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# === CONFIGURATION ===
$PLUGIN_NAME = "Claude Code Premium"
$VERSION = "1.0.0"
$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$BACKUP_DIR = "$CLAUDE_DIR\.backup"
$REPO_URL = "https://github.com/YOUR_USERNAME/claude-code-premium"

# === COLORS ===
function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Write-Header {
    Write-Host ""
    Write-Color "╔══════════════════════════════════════════════════════════╗" "Cyan"
    Write-Color "║          Claude Code Premium Plugin Installer            ║" "Cyan"
    Write-Color "║                     Version $VERSION                         ║" "Cyan"
    Write-Color "╚══════════════════════════════════════════════════════════╝" "Cyan"
    Write-Host ""
}

function Write-Success { param([string]$Text) Write-Color "  ✓ $Text" "Green" }
function Write-Info { param([string]$Text) Write-Color "  ℹ $Text" "Cyan" }
function Write-Warning { param([string]$Text) Write-Color "  ⚠ $Text" "Yellow" }
function Write-Error { param([string]$Text) Write-Color "  ✗ $Text" "Red" }

# === FUNCTIONS ===

function Test-ClaudeInstalled {
    $claudePath = Get-Command claude -ErrorAction SilentlyContinue
    return $null -ne $claudePath
}

function Backup-ExistingConfig {
    if (Test-Path "$CLAUDE_DIR\settings.json") {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        if (-not (Test-Path $BACKUP_DIR)) {
            New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
        }
        Copy-Item "$CLAUDE_DIR\settings.json" "$BACKUP_DIR\settings_$timestamp.json"
        Write-Info "Backed up existing settings.json"
    }
}

function Install-Plugin {
    Write-Info "Installing $PLUGIN_NAME..."

    # Create directories
    $dirs = @(
        $CLAUDE_DIR,
        "$CLAUDE_DIR\commands",
        "$CLAUDE_DIR\hooks",
        "$CLAUDE_DIR\history",
        "$CLAUDE_DIR\history\daily"
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    Write-Success "Created directory structure"

    # Get script directory
    $scriptDir = Split-Path -Parent $MyInvocation.PSCommandPath
    if (-not $scriptDir) { $scriptDir = Get-Location }

    # Copy status line
    $statuslineSrc = Join-Path $scriptDir "src\statusline.ps1"
    if (Test-Path $statuslineSrc) {
        Copy-Item $statuslineSrc "$CLAUDE_DIR\statusline.ps1" -Force
        Write-Success "Installed status line"
    } else {
        Write-Warning "statusline.ps1 not found in src/, creating from embedded..."
        # Will be created by settings
    }

    # Copy hooks
    $hooksSrc = Join-Path $scriptDir "src\hooks"
    if (Test-Path $hooksSrc) {
        Get-ChildItem "$hooksSrc\*.ps1" | ForEach-Object {
            Copy-Item $_.FullName "$CLAUDE_DIR\hooks\" -Force
        }
        Write-Success "Installed hooks"
    }

    # Copy commands (skills)
    $commandsSrc = Join-Path $scriptDir "src\commands"
    if (Test-Path $commandsSrc) {
        Get-ChildItem "$commandsSrc\*.md" | ForEach-Object {
            Copy-Item $_.FullName "$CLAUDE_DIR\commands\" -Force
        }
        $skillCount = (Get-ChildItem "$CLAUDE_DIR\commands\*.md").Count
        Write-Success "Installed $skillCount skills"
    }

    # Create/update settings.json
    $settings = @{
        statusLine = @{
            type = "command"
            command = "powershell -ExecutionPolicy Bypass -File `"$CLAUDE_DIR\statusline.ps1`""
            padding = 0
        }
        hooks = @{
            Stop = @(
                @{
                    type = "command"
                    command = "powershell -ExecutionPolicy Bypass -File `"$CLAUDE_DIR\hooks\save-session.ps1`""
                }
            )
        }
        permissions = @{
            allow = @(
                "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep", "LS",
                "NotebookEdit", "TodoRead", "TodoWrite", "WebFetch", "WebSearch",
                "Bash(git *)", "Bash(npm *)", "Bash(npx *)", "Bash(node *)",
                "Bash(python *)", "Bash(pip *)", "Bash(pnpm *)", "Bash(yarn *)",
                "Bash(cargo *)", "Bash(go *)", "Bash(mkdir *)", "Bash(ls *)",
                "Bash(cd *)", "Bash(cat *)", "Bash(echo *)", "Bash(pwd)",
                "Bash(which *)", "Bash(where *)", "Bash(code *)", "Bash(tsc *)",
                "Bash(eslint *)", "Bash(prettier *)", "Bash(jest *)",
                "Bash(vitest *)", "Bash(pytest *)"
            )
            deny = @()
        }
    }

    # Merge with existing settings if present
    if (Test-Path "$CLAUDE_DIR\settings.json") {
        try {
            $existing = Get-Content "$CLAUDE_DIR\settings.json" -Raw | ConvertFrom-Json -AsHashtable
            # Keep any custom settings not related to our plugin
            foreach ($key in $existing.Keys) {
                if ($key -notin @("statusLine", "hooks", "permissions")) {
                    $settings[$key] = $existing[$key]
                }
            }
        } catch {}
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content "$CLAUDE_DIR\settings.json" -Encoding UTF8
    Write-Success "Configured settings.json"

    # Save version info
    @{
        version = $VERSION
        installedAt = (Get-Date -Format "o")
        platform = "windows"
    } | ConvertTo-Json | Set-Content "$CLAUDE_DIR\.plugin-version" -Encoding UTF8
}

function Uninstall-Plugin {
    Write-Info "Uninstalling $PLUGIN_NAME..."

    $filesToRemove = @(
        "$CLAUDE_DIR\statusline.ps1",
        "$CLAUDE_DIR\.plugin-version"
    )

    foreach ($file in $filesToRemove) {
        if (Test-Path $file) {
            Remove-Item $file -Force
        }
    }

    # Remove commands
    if (Test-Path "$CLAUDE_DIR\commands") {
        Remove-Item "$CLAUDE_DIR\commands\*.md" -Force -ErrorAction SilentlyContinue
    }

    # Remove hooks
    if (Test-Path "$CLAUDE_DIR\hooks") {
        Remove-Item "$CLAUDE_DIR\hooks\*.ps1" -Force -ErrorAction SilentlyContinue
    }

    Write-Success "Plugin uninstalled"
    Write-Info "Your history and settings.json were preserved"
    Write-Info "To completely remove, delete: $CLAUDE_DIR"
}

# === MAIN ===

Write-Header

# Check Claude installation
if (-not (Test-ClaudeInstalled)) {
    Write-Warning "Claude Code CLI not found in PATH"
    Write-Info "Please install Claude Code first: npm install -g @anthropic-ai/claude-code"
    Write-Host ""

    if (-not $Force) {
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne "y") {
            exit 1
        }
    }
}

if ($Uninstall) {
    Backup-ExistingConfig
    Uninstall-Plugin
} else {
    Backup-ExistingConfig
    Install-Plugin

    Write-Host ""
    Write-Color "╔══════════════════════════════════════════════════════════╗" "Green"
    Write-Color "║              Installation Complete!                       ║" "Green"
    Write-Color "╚══════════════════════════════════════════════════════════╝" "Green"
    Write-Host ""
    Write-Info "Restart Claude Code to activate the plugin:"
    Write-Host "    claude" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "Available skills:"
    Get-ChildItem "$CLAUDE_DIR\commands\*.md" | ForEach-Object {
        Write-Host "    /$($_.BaseName)" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Info "To update later, run:"
    Write-Host "    .\install.ps1 -Update" -ForegroundColor Yellow
    Write-Host ""
}
