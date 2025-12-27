#!/usr/bin/env pwsh
# ============================================================================
# Claude Code Premium Status Line - Enhanced Edition
# Version: 2.0.0
# Description: Multi-line status bar with session and weekly statistics
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

# Weekly stats file
$weeklyStatsFile = Join-Path $env:USERPROFILE ".claude\weekly_stats.json"

# Read JSON from stdin
$inputJson = $input | Out-String
try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    Write-Output "${DIM}Loading...${RESET}"
    exit 0
}

# === WEEKLY STATS MANAGEMENT ===
function Get-WeeklyStats {
    $now = Get-Date
    $weekStart = $now.AddDays(-($now.DayOfWeek.value__)).Date

    $stats = @{
        week_start = $weekStart.ToString("yyyy-MM-dd")
        total_cost = 0
        total_tokens = 0
        total_duration_ms = 0
        sessions = 0
    }

    if (Test-Path $weeklyStatsFile) {
        try {
            $saved = Get-Content $weeklyStatsFile -Raw | ConvertFrom-Json
            if ($saved.week_start -eq $stats.week_start) {
                $stats.total_cost = $saved.total_cost
                $stats.total_tokens = $saved.total_tokens
                $stats.total_duration_ms = $saved.total_duration_ms
                $stats.sessions = $saved.sessions
            }
        } catch {}
    }

    return $stats
}

function Update-WeeklyStats($sessionCost, $sessionTokens, $sessionDuration) {
    $stats = Get-WeeklyStats

    # Create session ID to avoid double counting
    $sessionId = "$($data.workspace.project_dir)_$($data.cost.total_duration_ms)"
    $sessionIdFile = Join-Path $env:USERPROFILE ".claude\session_id.txt"

    $lastSessionId = ""
    if (Test-Path $sessionIdFile) {
        $lastSessionId = Get-Content $sessionIdFile -Raw
    }

    if ($sessionId -ne $lastSessionId) {
        $stats.total_cost += $sessionCost
        $stats.total_tokens += $sessionTokens
        $stats.total_duration_ms += $sessionDuration
        $stats.sessions += 1

        $statsDir = Split-Path $weeklyStatsFile -Parent
        if (-not (Test-Path $statsDir)) {
            New-Item -ItemType Directory -Path $statsDir -Force | Out-Null
        }

        $stats | ConvertTo-Json | Set-Content $weeklyStatsFile
        $sessionId | Set-Content $sessionIdFile
    }

    return $stats
}

# === DATA EXTRACTION ===

# Model
$model = if ($data.model.display_name) { $data.model.display_name } else { "Unknown" }
$modelFull = switch ($model) {
    "Opus" { "Claude Opus 4" }
    "Sonnet" { "Claude Sonnet 4" }
    "Haiku" { "Claude Haiku" }
    default { $model }
}
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
$totalSeconds = [math]::Floor($durationMs / 1000)
$hours = [math]::Floor($totalSeconds / 3600)
$minutes = [math]::Floor(($totalSeconds % 3600) / 60)
$seconds = $totalSeconds % 60

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
$remainingPercent = 100 - $contextPercent

# Tokens per minute
$tokensPerMin = 0
if ($durationMs -gt 60000) {
    $tokensPerMin = [math]::Round(($usedTokens * 60000) / $durationMs)
}

# Estimated time until context reset (at current rate)
$resetTimeStr = "N/A"
if ($tokensPerMin -gt 0) {
    $remainingTokens = $contextSize - $usedTokens
    $remainingMinutes = [math]::Floor($remainingTokens / $tokensPerMin)
    $resetHours = [math]::Floor($remainingMinutes / 60)
    $resetMins = $remainingMinutes % 60
    $resetTimeStr = if ($resetHours -gt 0) { "~${resetHours}h ${resetMins}m" } else { "~${resetMins}m" }
}

# Context color based on level
$contextColor = switch ($true) {
    ($contextPercent -ge 80) { $RED }
    ($contextPercent -ge 60) { $YELLOW }
    ($contextPercent -ge 40) { $CYAN }
    default { $GREEN }
}

# Progress bar (15 segments)
$barWidth = 15
$filledSegments = [math]::Floor(($contextPercent * $barWidth) / 100)
$emptySegments = $barWidth - $filledSegments
$progressBar = "[${contextColor}" + ("=" * $filledSegments) + "${GRAY}" + ("-" * $emptySegments) + "${RESET}]"

# Version (from VERSION file if exists)
$version = "1.0.0"
$versionFile = Join-Path (Split-Path $PSScriptRoot -Parent) "VERSION"
if (Test-Path $versionFile) {
    $version = (Get-Content $versionFile -Raw).Trim()
}

# Weekly stats
$weeklyStats = Update-WeeklyStats $cost $usedTokens $durationMs
$weeklyCost = "{0:N2}" -f $weeklyStats.total_cost
$weeklyTokens = "{0:N0}" -f $weeklyStats.total_tokens
$weeklyDurationMin = [math]::Floor($weeklyStats.total_duration_ms / 60000)
$weeklyHours = [math]::Floor($weeklyDurationMin / 60)
$weeklyMins = $weeklyDurationMin % 60
$weeklyTimeStr = if ($weeklyHours -gt 0) { "${weeklyHours}h${weeklyMins}m" } else { "${weeklyMins}m" }

# Lines modified
$linesAdded = if ($data.cost.total_lines_added) { $data.cost.total_lines_added } else { 0 }
$linesRemoved = if ($data.cost.total_lines_removed) { $data.cost.total_lines_removed } else { 0 }

# === BUILD OUTPUT ===

# Line 1: Project info
$line1Parts = @()
$line1Parts += "${BLUE}📁 ${BOLD}$displayPath${RESET}"
if ($gitBranch) {
    $branchColor = if ($gitDirty) { $YELLOW } else { $GREEN }
    $dirtyMark = if ($gitDirty) { "*" } else { "" }
    $line1Parts += "${branchColor}🌿 $gitBranch$dirtyMark${RESET}"
}
$line1Parts += "${modelColor}🤖 $modelFull${RESET}"
$line1Parts += "${GRAY}📟 v$version${RESET}"
$line1 = $line1Parts -join "  "

# Line 2: Session timing
$timeStr = if ($hours -gt 0) { "${hours}h ${minutes}m ${seconds}s" } else { "${minutes}m ${seconds}s" }
$line2 = "${CYAN}⏱️  Session: ${BOLD}$timeStr${RESET}"

# Line 3: Context usage
$tokensFormatted = "{0:N0}" -f $usedTokens
$line3 = "${contextColor}🧠 Context: ${BOLD}${contextPercent}%${RESET} used / ${GREEN}${remainingPercent}%${RESET} remaining $progressBar  ${GRAY}⏳ Reset in: $resetTimeStr${RESET}"

# Line 4: Cost and tokens
$costColor = switch ($true) {
    ($cost -gt 10) { $RED }
    ($cost -gt 5) { $YELLOW }
    default { $GREEN }
}
$line4Parts = @()
$line4Parts += "${costColor}💰 `$$costDisplay${RESET}"
if ($hourlyRate -gt 0) {
    $line4Parts += "${DIM}(`$$hourlyRate/h)${RESET}"
}
$line4Parts += "${GRAY}📊 $tokensFormatted tok${RESET}"
if ($tokensPerMin -gt 0) {
    $line4Parts += "${DIM}(${tokensPerMin} tpm)${RESET}"
}
if ($linesAdded -gt 0 -or $linesRemoved -gt 0) {
    $line4Parts += "${GREEN}+$linesAdded${RESET}/${RED}-$linesRemoved${RESET}"
}
$line4 = $line4Parts -join "  "

# Line 5: Weekly stats
$line5 = "${MAGENTA}📅 This week:${RESET} ${DIM}$($weeklyStats.sessions) sessions${RESET}  ${YELLOW}💵 `$$weeklyCost${RESET}  ${GRAY}🕐 $weeklyTimeStr${RESET}  ${CYAN}📈 $weeklyTokens tok${RESET}"

# Output all lines
Write-Output $line1
Write-Output $line2
Write-Output $line3
Write-Output $line4
Write-Output $line5
