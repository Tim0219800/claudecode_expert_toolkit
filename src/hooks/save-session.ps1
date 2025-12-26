#!/usr/bin/env pwsh
# ============================================================================
# Claude Code Session Saver Hook
# Automatically saves session data on exit
# ============================================================================

param()

$inputJson = $input | Out-String
try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    exit 0
}

# Extract info
$sessionId = $data.session_id
$projectDir = if ($data.workspace.project_dir) { $data.workspace.project_dir } else { $data.workspace.current_dir }
$transcriptPath = $data.transcript_path
$cost = if ($data.cost.total_cost_usd) { $data.cost.total_cost_usd } else { 0 }
$durationMs = if ($data.cost.total_duration_ms) { $data.cost.total_duration_ms } else { 0 }
$linesAdded = if ($data.cost.total_lines_added) { $data.cost.total_lines_added } else { 0 }
$linesRemoved = if ($data.cost.total_lines_removed) { $data.cost.total_lines_removed } else { 0 }
$model = if ($data.model.display_name) { $data.model.display_name } else { "Unknown" }

# Create history directory
$historyDir = "$env:USERPROFILE\.claude\history"
if (-not $historyDir) { $historyDir = "$env:HOME/.claude/history" }
if (-not (Test-Path $historyDir)) {
    New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
}

# Timestamps
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$dateOnly = Get-Date -Format "yyyy-MM-dd"

# Project name
$projectName = Split-Path $projectDir -Leaf

# Copy transcript
if ($transcriptPath -and (Test-Path $transcriptPath)) {
    $destFile = "$historyDir\${timestamp}_${projectName}_$($sessionId.Substring(0,8)).jsonl"
    Copy-Item $transcriptPath $destFile -Force
}

# Update session index
$indexFile = "$historyDir\sessions-index.json"
$sessions = @()

if (Test-Path $indexFile) {
    try {
        $content = Get-Content $indexFile -Raw
        if ($content) {
            $sessions = $content | ConvertFrom-Json
            if ($sessions -isnot [array]) { $sessions = @($sessions) }
        }
    } catch {
        $sessions = @()
    }
}

# Add this session
$newSession = [PSCustomObject]@{
    id = $sessionId
    date = $timestamp
    project = $projectName
    projectPath = $projectDir
    model = $model
    cost = [math]::Round($cost, 4)
    durationMinutes = [math]::Round($durationMs / 60000, 1)
    linesAdded = $linesAdded
    linesRemoved = $linesRemoved
    transcriptFile = "${timestamp}_${projectName}_$($sessionId.Substring(0,8)).jsonl"
}

$sessions = @($newSession) + @($sessions)

# Keep last 100 sessions
if ($sessions.Count -gt 100) {
    $sessions = $sessions[0..99]
}

# Save index
$sessions | ConvertTo-Json -Depth 10 | Set-Content $indexFile -Encoding UTF8

# Create daily summary
$dailyDir = "$historyDir\daily"
if (-not (Test-Path $dailyDir)) {
    New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null
}

$summaryFile = "$dailyDir\$dateOnly.md"
$summaryEntry = @"

---
## Session: $timestamp
- **Project**: $projectName
- **Model**: $model
- **Cost**: `$$([math]::Round($cost, 2))
- **Duration**: $([math]::Round($durationMs / 60000, 0)) minutes
- **Lines**: +$linesAdded / -$linesRemoved

"@

Add-Content $summaryFile $summaryEntry -Encoding UTF8
