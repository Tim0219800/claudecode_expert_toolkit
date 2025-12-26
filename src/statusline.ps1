#!/usr/bin/env pwsh
# ============================================================================
# Claude Code Premium Status Line
# Version: 1.0.0
# Author: Claude Code Community
# Description: Beautiful real-time status bar with colors and progress
# ============================================================================

param()

# === ANSI COLOR CODES ===
$ESC = [char]27
$RESET = "$ESC[0m"
$BOLD = "$ESC[1m"
$DIM = "$ESC[2m"

# Colors
$CYAN = "$ESC[36m"
$GREEN = "$ESC[32m"
$YELLOW = "$ESC[33m"
$RED = "$ESC[31m"
$MAGENTA = "$ESC[35m"
$BLUE = "$ESC[34m"
$WHITE = "$ESC[97m"
$GRAY = "$ESC[90m"

# Read JSON from stdin
$inputJson = $input | Out-String
try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    Write-Output "${DIM}Loading...${RESET}"
    exit 0
}

# === DATA EXTRACTION ===

# Model
$model = if ($data.model.display_name) { $data.model.display_name } else { "Unknown" }
$modelColor = switch ($model) {
    "Opus" { $MAGENTA }
    "Sonnet" { $CYAN }
    "Haiku" { $GREEN }
    default { $WHITE }
}

# Project path
$projectDir = if ($data.workspace.project_dir) { $data.workspace.project_dir } else { $data.workspace.current_dir }
$homeDir = $env:USERPROFILE -replace '\\', '/'
if (-not $homeDir) { $homeDir = $env:HOME -replace '\\', '/' }
$displayPath = $projectDir -replace '\\', '/'
$displayPath = $displayPath -replace [regex]::Escape($homeDir), '~'
$pathParts = $displayPath -split '/'
if ($pathParts.Count -gt 3) {
    $displayPath = "~/" + ($pathParts[-2..-1] -join '/')
}

# Git branch
$gitBranch = ""
$gitDirty = $false
$gitDir = Join-Path $projectDir ".git"
if (Test-Path $gitDir -ErrorAction SilentlyContinue) {
    try {
        Push-Location $projectDir
        $branch = git branch --show-current 2>$null
        $dirty = (git status --porcelain 2>$null | Measure-Object -Line).Lines
        if ($branch) {
            $gitBranch = $branch
            $gitDirty = ($dirty -gt 0)
        }
        Pop-Location
    } catch {}
}

# Cost
$cost = if ($data.cost.total_cost_usd) { $data.cost.total_cost_usd } else { 0 }
$costDisplay = if ($cost -lt 0.01) { "<0.01" } else { "{0:N2}" -f $cost }

# Duration
$durationMs = if ($data.cost.total_duration_ms) { $data.cost.total_duration_ms } else { 0 }
$durationMin = [math]::Floor($durationMs / 60000)
$hours = [math]::Floor($durationMin / 60)
$minutes = $durationMin % 60

# Hourly rate
$hourlyRate = 0
if ($durationMs -gt 60000) {
    $hourlyRate = [math]::Round(($cost * 3600000) / $durationMs, 2)
}

# Context / Tokens
$contextSize = if ($data.context_window.context_window_size) { $data.context_window.context_window_size } else { 200000 }
$usedTokens = 0
if ($data.context_window.current_usage) {
    $cu = $data.context_window.current_usage
    $usedTokens = (
        [int]$cu.input_tokens +
        [int]$cu.output_tokens +
        [int]$cu.cache_creation_input_tokens +
        [int]$cu.cache_read_input_tokens
    )
}
$contextPercent = [math]::Floor(($usedTokens * 100) / $contextSize)

# Context color based on level
$contextColor = switch ($true) {
    ($contextPercent -ge 80) { $RED }
    ($contextPercent -ge 60) { $YELLOW }
    ($contextPercent -ge 40) { $CYAN }
    default { $GREEN }
}

# Progress bar (10 segments)
$filledSegments = [math]::Floor($contextPercent / 10)
$emptySegments = 10 - $filledSegments
$progressBar = ("$contextColor" + ([string][char]0x2588 * $filledSegments) + "$GRAY" + ([string][char]0x2591 * $emptySegments) + "$RESET")

# Lines modified
$linesAdded = if ($data.cost.total_lines_added) { $data.cost.total_lines_added } else { 0 }
$linesRemoved = if ($data.cost.total_lines_removed) { $data.cost.total_lines_removed } else { 0 }

# === BUILD OUTPUT LINE ===

$parts = @()

# Path
$parts += "${BLUE}${BOLD}$displayPath${RESET}"

# Git branch
if ($gitBranch) {
    $branchColor = if ($gitDirty) { $YELLOW } else { $GREEN }
    $dirtyMark = if ($gitDirty) { "*" } else { "" }
    $parts += "${branchColor}$gitBranch$dirtyMark${RESET}"
}

# Model
$parts += "${modelColor}${BOLD}$model${RESET}"

# Duration
$timeStr = if ($hours -gt 0) { "${hours}h${minutes}m" } else { "${minutes}m" }
$parts += "${GRAY}$timeStr${RESET}"

# Context bar with percentage
$parts += "$progressBar ${contextColor}${contextPercent}%${RESET}"

# Cost
$costColor = switch ($true) {
    ($cost -gt 10) { $RED }
    ($cost -gt 5) { $YELLOW }
    default { $GREEN }
}
$costStr = "${costColor}`$$costDisplay${RESET}"
if ($hourlyRate -gt 0) {
    $costStr += " ${DIM}(`$$hourlyRate/h)${RESET}"
}
$parts += $costStr

# Lines modified (if > 0)
if ($linesAdded -gt 0 -or $linesRemoved -gt 0) {
    $parts += "${GREEN}+$linesAdded${RESET}${GRAY}/${RESET}${RED}-$linesRemoved${RESET}"
}

# Elegant separator
$separator = " ${GRAY}|${RESET} "
$output = $parts -join $separator

Write-Output $output
