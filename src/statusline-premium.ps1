#!/usr/bin/env pwsh
# ============================================================================
# Claude Code Status Line - With Real Account Usage
# Version: 4.0.0
# ============================================================================

param()

$ESC = [char]27
$RESET = "$ESC[0m"
$BOLD = "$ESC[1m"
$DIM = "$ESC[2m"
$CYAN = "$ESC[36m"
$GREEN = "$ESC[32m"
$YELLOW = "$ESC[33m"
$RED = "$ESC[31m"
$MAGENTA = "$ESC[35m"
$BLUE = "$ESC[34m"
$GRAY = "$ESC[90m"

# Read JSON from stdin
$inputJson = $input | Out-String
try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    Write-Output "${DIM}...${RESET}"
    exit 0
}

# === GET REAL USAGE FROM API ===
$sessionPct = $null
$weeklyPct = $null
$sessionReset = $null
$weeklyReset = $null

try {
    $credsFile = Join-Path $env:USERPROFILE ".claude\.credentials.json"
    if (Test-Path $credsFile) {
        $creds = Get-Content $credsFile -Raw | ConvertFrom-Json
        $token = $creds.claudeAiOauth.accessToken

        $headers = @{
            "Authorization" = "Bearer $token"
            "anthropic-beta" = "oauth-2025-04-20"
        }

        $usage = Invoke-RestMethod -Uri "https://api.anthropic.com/api/oauth/usage" -Headers $headers -Method Get -TimeoutSec 3

        if ($usage.five_hour) {
            $sessionPct = [math]::Round($usage.five_hour.utilization)
            if ($usage.five_hour.resets_at) {
                $resetTime = [DateTime]::Parse($usage.five_hour.resets_at)
                $diff = $resetTime - (Get-Date)
                $sessionReset = "{0}h{1:D2}m" -f [math]::Floor($diff.TotalHours), $diff.Minutes
            }
        }

        if ($usage.seven_day) {
            $weeklyPct = [math]::Round($usage.seven_day.utilization)
            if ($usage.seven_day.resets_at) {
                $resetTime = [DateTime]::Parse($usage.seven_day.resets_at)
                $diff = $resetTime - (Get-Date)
                $weeklyReset = "{0}j" -f [math]::Ceiling($diff.TotalDays)
            }
        }
    }
} catch {
    # API failed, continue without usage data
}

# === MODEL ===
$model = if ($data.model.display_name) { $data.model.display_name } else { "?" }
$modelColor = switch ($model) {
    "Opus" { $MAGENTA }
    "Sonnet" { $CYAN }
    "Haiku" { $GREEN }
    default { $GRAY }
}

# === PROJECT ===
$projectDir = if ($data.workspace.project_dir) { $data.workspace.project_dir } else { $data.workspace.current_dir }
$homeDir = $env:USERPROFILE -replace '\\', '/'
if (-not $homeDir) { $homeDir = $env:HOME -replace '\\', '/' }
$displayPath = $projectDir -replace '\\', '/'
$displayPath = $displayPath -replace [regex]::Escape($homeDir), '~'
$pathParts = $displayPath -split '/'
if ($pathParts.Count -gt 3) {
    $displayPath = "~/" + ($pathParts[-2..-1] -join '/')
}

# === GIT ===
$gitBranch = ""
$gitDirty = $false
if ($projectDir) {
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
}

# === SESSION DATA ===
$cost = if ($data.cost.total_cost_usd) { [double]$data.cost.total_cost_usd } else { 0 }
$costDisplay = if ($cost -lt 0.01) { "<0.01" } else { "{0:F2}" -f $cost }

$durationMs = if ($data.cost.total_duration_ms) { [long]$data.cost.total_duration_ms } else { 0 }
$totalSeconds = [math]::Floor($durationMs / 1000)
$hours = [math]::Floor($totalSeconds / 3600)
$minutes = [math]::Floor(($totalSeconds % 3600) / 60)
$timeStr = if ($hours -gt 0) { "${hours}h${minutes}m" } else { "${minutes}m" }

# === CONTEXT WINDOW ===
$contextSize = if ($data.context_window.context_window_size) { $data.context_window.context_window_size } else { 200000 }
$usedTokens = 0
if ($data.context_window.current_usage) {
    $cu = $data.context_window.current_usage
    $usedTokens = [long]$cu.input_tokens + [long]$cu.output_tokens + [long]$cu.cache_creation_input_tokens + [long]$cu.cache_read_input_tokens
}
$contextPercent = [math]::Min(100, [math]::Floor(($usedTokens * 100) / $contextSize))

$contextColor = switch ($true) {
    ($contextPercent -ge 80) { $RED }
    ($contextPercent -ge 60) { $YELLOW }
    default { $GREEN }
}

# === LINES ===
$linesAdded = if ($data.cost.total_lines_added) { $data.cost.total_lines_added } else { 0 }
$linesRemoved = if ($data.cost.total_lines_removed) { $data.cost.total_lines_removed } else { 0 }

# === HELPER: Progress bar ===
function Get-Bar($pct, $width, $color) {
    $filled = [math]::Floor(($pct * $width) / 100)
    $empty = $width - $filled
    return "${color}" + ("=" * $filled) + "${GRAY}" + ("-" * $empty) + "${RESET}"
}

# === OUTPUT ===

# Line 1: Project + Git + Model + Duration
$line1 = "${BLUE}$displayPath${RESET}"
if ($gitBranch) {
    $branchColor = if ($gitDirty) { $YELLOW } else { $GREEN }
    $mark = if ($gitDirty) { "*" } else { "" }
    $line1 += " ${branchColor}($gitBranch$mark)${RESET}"
}
$line1 += "  ${modelColor}${BOLD}$model${RESET}  ${GRAY}$timeStr${RESET}"

# Line 2: Real account usage (session + weekly)
if ($null -ne $sessionPct) {
    $sessColor = switch ($true) { ($sessionPct -ge 80) { $RED } ($sessionPct -ge 50) { $YELLOW } default { $GREEN } }
    $weekColor = switch ($true) { ($weeklyPct -ge 80) { $RED } ($weeklyPct -ge 50) { $YELLOW } default { $GREEN } }

    $sessBar = Get-Bar $sessionPct 8 $sessColor
    $weekBar = Get-Bar $weeklyPct 8 $weekColor

    $line2 = "${sessColor}5H ${BOLD}${sessionPct}%${RESET} [$sessBar]"
    if ($sessionReset) { $line2 += " ${DIM}$sessionReset${RESET}" }
    $line2 += "  ${weekColor}7J ${BOLD}${weeklyPct}%${RESET} [$weekBar]"
    if ($weeklyReset) { $line2 += " ${DIM}$weeklyReset${RESET}" }
} else {
    $line2 = "${GRAY}Usage: --${RESET}"
}

# Line 3: Context + Cost + Lines
$ctxBar = Get-Bar $contextPercent 10 $contextColor
$tokensK = [math]::Round($usedTokens / 1000, 1)

$costColor = switch ($true) { ($cost -gt 5) { $RED } ($cost -gt 2) { $YELLOW } default { $GREEN } }

$line3 = "${contextColor}CTX ${contextPercent}%${RESET} [$ctxBar] ${tokensK}k"
$line3 += "  ${costColor}`$$costDisplay${RESET}"
if ($linesAdded -gt 0 -or $linesRemoved -gt 0) {
    $line3 += "  ${GREEN}+$linesAdded${RESET}/${RED}-$linesRemoved${RESET}"
}

Write-Output $line1
Write-Output $line2
Write-Output $line3
