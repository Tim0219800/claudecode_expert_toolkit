#!/bin/bash
# ============================================================================
# Claude Code Premium Status Line
# Version: 1.0.0
# Author: Claude Code Community
# Description: Beautiful real-time status bar with colors and progress
# ============================================================================

# === ANSI COLOR CODES ===
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
BLUE="\033[34m"
WHITE="\033[97m"
GRAY="\033[90m"

# Read JSON from stdin
input=$(cat)

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Loading..."
    exit 0
fi

# === HELPER FUNCTIONS ===

get_json_value() {
    echo "$input" | jq -r "$1 // \"$2\"" 2>/dev/null || echo "$2"
}

get_json_number() {
    echo "$input" | jq -r "$1 // 0" 2>/dev/null || echo "0"
}

# === DATA EXTRACTION ===

# Model
model=$(get_json_value '.model.display_name' 'Unknown')
case "$model" in
    "Opus") modelColor="$MAGENTA" ;;
    "Sonnet") modelColor="$CYAN" ;;
    "Haiku") modelColor="$GREEN" ;;
    *) modelColor="$WHITE" ;;
esac

# Project path
projectDir=$(get_json_value '.workspace.project_dir' "$(get_json_value '.workspace.current_dir' '/')")
displayPath="${projectDir/#$HOME/\~}"
# Shorten if too long
pathDepth=$(echo "$displayPath" | tr '/' '\n' | wc -l)
if [ "$pathDepth" -gt 3 ]; then
    displayPath="~/$(echo "$displayPath" | rev | cut -d'/' -f1-2 | rev)"
fi

# Git branch
gitBranch=""
gitDirty=""
if [ -d "$projectDir/.git" ]; then
    gitBranch=$(git -C "$projectDir" branch --show-current 2>/dev/null)
    if [ -n "$gitBranch" ]; then
        dirtyCount=$(git -C "$projectDir" status --porcelain 2>/dev/null | wc -l)
        if [ "$dirtyCount" -gt 0 ]; then
            gitDirty="*"
        fi
    fi
fi

# Cost
cost=$(get_json_number '.cost.total_cost_usd')
if (( $(echo "$cost < 0.01" | bc -l 2>/dev/null || echo 0) )); then
    costDisplay="<0.01"
else
    costDisplay=$(printf "%.2f" "$cost")
fi

# Duration
durationMs=$(get_json_number '.cost.total_duration_ms')
durationMin=$((durationMs / 60000))
hours=$((durationMin / 60))
minutes=$((durationMin % 60))

# Hourly rate
hourlyRate=0
if [ "$durationMs" -gt 60000 ]; then
    hourlyRate=$(echo "scale=2; $cost * 3600000 / $durationMs" | bc -l 2>/dev/null || echo "0")
fi

# Context / Tokens
contextSize=$(get_json_number '.context_window.context_window_size')
[ "$contextSize" -eq 0 ] && contextSize=200000

inputTokens=$(get_json_number '.context_window.current_usage.input_tokens')
outputTokens=$(get_json_number '.context_window.current_usage.output_tokens')
cacheCreate=$(get_json_number '.context_window.current_usage.cache_creation_input_tokens')
cacheRead=$(get_json_number '.context_window.current_usage.cache_read_input_tokens')
usedTokens=$((inputTokens + outputTokens + cacheCreate + cacheRead))
contextPercent=$((usedTokens * 100 / contextSize))

# Context color
if [ "$contextPercent" -ge 80 ]; then
    contextColor="$RED"
elif [ "$contextPercent" -ge 60 ]; then
    contextColor="$YELLOW"
elif [ "$contextPercent" -ge 40 ]; then
    contextColor="$CYAN"
else
    contextColor="$GREEN"
fi

# Progress bar
filledSegments=$((contextPercent / 10))
emptySegments=$((10 - filledSegments))
progressBar="${contextColor}$(printf '█%.0s' $(seq 1 $filledSegments 2>/dev/null))${GRAY}$(printf '░%.0s' $(seq 1 $emptySegments 2>/dev/null))${RESET}"

# Lines modified
linesAdded=$(get_json_number '.cost.total_lines_added')
linesRemoved=$(get_json_number '.cost.total_lines_removed')

# === BUILD OUTPUT ===

parts=()

# Path
parts+=("${BLUE}${BOLD}${displayPath}${RESET}")

# Git branch
if [ -n "$gitBranch" ]; then
    if [ -n "$gitDirty" ]; then
        parts+=("${YELLOW}${gitBranch}${gitDirty}${RESET}")
    else
        parts+=("${GREEN}${gitBranch}${RESET}")
    fi
fi

# Model
parts+=("${modelColor}${BOLD}${model}${RESET}")

# Duration
if [ "$hours" -gt 0 ]; then
    timeStr="${hours}h${minutes}m"
else
    timeStr="${minutes}m"
fi
parts+=("${GRAY}${timeStr}${RESET}")

# Context bar
parts+=("${progressBar} ${contextColor}${contextPercent}%${RESET}")

# Cost
if (( $(echo "$cost > 10" | bc -l 2>/dev/null || echo 0) )); then
    costColor="$RED"
elif (( $(echo "$cost > 5" | bc -l 2>/dev/null || echo 0) )); then
    costColor="$YELLOW"
else
    costColor="$GREEN"
fi
costStr="${costColor}\$${costDisplay}${RESET}"
if (( $(echo "$hourlyRate > 0" | bc -l 2>/dev/null || echo 0) )); then
    costStr="${costStr} ${DIM}(\$${hourlyRate}/h)${RESET}"
fi
parts+=("$costStr")

# Lines modified
if [ "$linesAdded" -gt 0 ] || [ "$linesRemoved" -gt 0 ]; then
    parts+=("${GREEN}+${linesAdded}${RESET}${GRAY}/${RESET}${RED}-${linesRemoved}${RESET}")
fi

# Join with separator
separator=" ${GRAY}|${RESET} "
output=""
for i in "${!parts[@]}"; do
    if [ $i -gt 0 ]; then
        output="${output}${separator}"
    fi
    output="${output}${parts[$i]}"
done

echo -e "$output"
