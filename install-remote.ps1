<#
.SYNOPSIS
    One-liner remote installer for Claude Code Premium
.DESCRIPTION
    Downloads and installs the plugin directly from GitHub
.EXAMPLE
    iwr -useb https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.ps1 | iex
#>

$ErrorActionPreference = "Stop"

$REPO = "Tim0219800/claudecode_expert_toolkit"
$BRANCH = "main"
$TEMP_DIR = "$env:TEMP\claudecode_expert_toolkit-install"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Claude Code Premium - Remote Installer                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Clean up any previous install attempt
if (Test-Path $TEMP_DIR) {
    Remove-Item $TEMP_DIR -Recurse -Force
}

# Download
Write-Host "  Downloading from GitHub..." -ForegroundColor Cyan
$zipUrl = "https://github.com/$REPO/archive/refs/heads/$BRANCH.zip"
$zipPath = "$env:TEMP\claudecode_expert_toolkit.zip"

Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# Extract
Write-Host "  Extracting..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR -Force

# Find extracted folder
$extractedFolder = Get-ChildItem $TEMP_DIR | Select-Object -First 1

# Run installer
Write-Host "  Running installer..." -ForegroundColor Cyan
Push-Location $extractedFolder.FullName
& ".\install.ps1"
Pop-Location

# Cleanup
Remove-Item $zipPath -Force
Remove-Item $TEMP_DIR -Recurse -Force

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
