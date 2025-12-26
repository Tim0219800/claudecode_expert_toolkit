#!/bin/bash
# ============================================================================
# Claude Code Session Saver Hook
# Automatically saves session data on exit
# ============================================================================

input=$(cat)

# Check jq
if ! command -v jq &> /dev/null; then
    exit 0
fi

# Extract info
sessionId=$(echo "$input" | jq -r '.session_id // ""')
projectDir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // "/"')
transcriptPath=$(echo "$input" | jq -r '.transcript_path // ""')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
durationMs=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
linesAdded=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
linesRemoved=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Create history directory
historyDir="$HOME/.claude/history"
mkdir -p "$historyDir/daily"

# Timestamps
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
dateOnly=$(date +"%Y-%m-%d")

# Project name
projectName=$(basename "$projectDir")

# Copy transcript
if [ -n "$transcriptPath" ] && [ -f "$transcriptPath" ]; then
    cp "$transcriptPath" "$historyDir/${timestamp}_${projectName}_${sessionId:0:8}.jsonl"
fi

# Update session index
indexFile="$historyDir/sessions-index.json"

# Create new session entry
newSession=$(cat <<EOF
{
    "id": "$sessionId",
    "date": "$timestamp",
    "project": "$projectName",
    "projectPath": "$projectDir",
    "model": "$model",
    "cost": $cost,
    "durationMinutes": $(echo "scale=1; $durationMs / 60000" | bc),
    "linesAdded": $linesAdded,
    "linesRemoved": $linesRemoved,
    "transcriptFile": "${timestamp}_${projectName}_${sessionId:0:8}.jsonl"
}
EOF
)

# Load existing or create new
if [ -f "$indexFile" ]; then
    # Prepend new session and keep last 100
    jq --argjson new "$newSession" '[$new] + . | .[0:100]' "$indexFile" > "$indexFile.tmp"
    mv "$indexFile.tmp" "$indexFile"
else
    echo "[$newSession]" > "$indexFile"
fi

# Daily summary
summaryFile="$historyDir/daily/$dateOnly.md"
cat >> "$summaryFile" <<EOF

---
## Session: $timestamp
- **Project**: $projectName
- **Model**: $model
- **Cost**: \$$(printf "%.2f" $cost)
- **Duration**: $((durationMs / 60000)) minutes
- **Lines**: +$linesAdded / -$linesRemoved

EOF
