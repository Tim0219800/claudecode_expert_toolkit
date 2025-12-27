#!/usr/bin/env bash
# ============================================================================
# Claude Code Premium Status Line - Enhanced Edition
# Version: 2.0.0
# Description: Multi-line status bar with session and weekly statistics
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

# Weekly stats file
WEEKLY_STATS_FILE="$HOME/.claude/weekly_stats.json"
SESSION_ID_FILE="$HOME/.claude/session_id.txt"

# Read JSON from stdin
INPUT_JSON=$(cat)

if [ -z "$INPUT_JSON" ]; then
    echo -e "${DIM}Loading...${RESET}"
    exit 0
fi

# === JSON PARSING HELPERS ===
get_json_value() {
    echo "$INPUT_JSON" | grep -o "\"$1\":[^,}]*" | head -1 | sed 's/.*://' | tr -d ' "' 2>/dev/null
}

get_nested_value() {
    echo "$INPUT_JSON" | grep -o "\"$1\":{[^}]*}" | grep -o "\"$2\":[^,}]*" | head -1 | sed 's/.*://' | tr -d ' "' 2>/dev/null
}

# === WEEKLY STATS ===
get_week_start() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -v-$(date +%u)d +%Y-%m-%d
    else
        date -d "last sunday" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d
    fi
}

update_weekly_stats() {
    local session_cost=$1
    local session_tokens=$2
    local session_duration=$3

    local week_start=$(get_week_start)

    mkdir -p "$HOME/.claude"

    # Initialize or load weekly stats
    local total_cost=0
    local total_tokens=0
    local total_duration=0
    local sessions=0

    if [ -f "$WEEKLY_STATS_FILE" ]; then
        local saved_week=$(grep -o '"week_start":"[^"]*"' "$WEEKLY_STATS_FILE" | cut -d'"' -f4)
        if [ "$saved_week" = "$week_start" ]; then
            total_cost=$(grep -o '"total_cost":[0-9.]*' "$WEEKLY_STATS_FILE" | cut -d':' -f2)
            total_tokens=$(grep -o '"total_tokens":[0-9]*' "$WEEKLY_STATS_FILE" | cut -d':' -f2)
            total_duration=$(grep -o '"total_duration_ms":[0-9]*' "$WEEKLY_STATS_FILE" | cut -d':' -f2)
            sessions=$(grep -o '"sessions":[0-9]*' "$WEEKLY_STATS_FILE" | cut -d':' -f2)
        fi
    fi

    # Session deduplication
    local project_dir=$(get_nested_value "workspace" "project_dir")
    local duration_ms=$(get_nested_value "cost" "total_duration_ms")
    local session_id="${project_dir}_${duration_ms}"

    local last_session_id=""
    if [ -f "$SESSION_ID_FILE" ]; then
        last_session_id=$(cat "$SESSION_ID_FILE")
    fi

    if [ "$session_id" != "$last_session_id" ]; then
        total_cost=$(echo "$total_cost + $session_cost" | bc 2>/dev/null || echo "$total_cost")
        total_tokens=$((total_tokens + session_tokens))
        total_duration=$((total_duration + session_duration))
        sessions=$((sessions + 1))

        cat > "$WEEKLY_STATS_FILE" << EOF
{"week_start":"$week_start","total_cost":$total_cost,"total_tokens":$total_tokens,"total_duration_ms":$total_duration,"sessions":$sessions}
EOF
        echo "$session_id" > "$SESSION_ID_FILE"
    fi

    echo "$total_cost|$total_tokens|$total_duration|$sessions"
}

# === DATA EXTRACTION ===

# Model
model=$(get_nested_value "model" "display_name")
[ -z "$model" ] && model="Unknown"

case "$model" in
    "Opus") model_full="Claude Opus 4"; model_color=$MAGENTA ;;
    "Sonnet") model_full="Claude Sonnet 4"; model_color=$CYAN ;;
    "Haiku") model_full="Claude Haiku"; model_color=$GREEN ;;
    *) model_full="$model"; model_color=$WHITE ;;
esac

# Project path
project_dir=$(get_nested_value "workspace" "project_dir")
[ -z "$project_dir" ] && project_dir=$(get_nested_value "workspace" "current_dir")
display_path="${project_dir/$HOME/\~}"
# Shorten long paths
if [[ $(echo "$display_path" | tr '/' '\n' | wc -l) -gt 3 ]]; then
    display_path="~/$(basename "$(dirname "$project_dir")")/$(basename "$project_dir")"
fi

# Git branch
git_branch=""
git_dirty=false
if [ -d "$project_dir/.git" ]; then
    cd "$project_dir" 2>/dev/null
    git_branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git_dirty=true
    fi
    cd - >/dev/null 2>&1
fi

# Cost
cost=$(get_nested_value "cost" "total_cost_usd")
[ -z "$cost" ] && cost=0
if (( $(echo "$cost < 0.01" | bc -l 2>/dev/null || echo 0) )); then
    cost_display="<0.01"
else
    cost_display=$(printf "%.2f" "$cost")
fi

# Duration
duration_ms=$(get_nested_value "cost" "total_duration_ms")
[ -z "$duration_ms" ] && duration_ms=0
total_seconds=$((duration_ms / 1000))
hours=$((total_seconds / 3600))
minutes=$(((total_seconds % 3600) / 60))
seconds=$((total_seconds % 60))

# Hourly rate
hourly_rate=0
if [ "$duration_ms" -gt 60000 ]; then
    hourly_rate=$(echo "scale=2; $cost * 3600000 / $duration_ms" | bc 2>/dev/null || echo "0")
fi

# Context / Tokens
context_size=$(get_nested_value "context_window" "context_window_size")
[ -z "$context_size" ] && context_size=200000

input_tokens=$(echo "$INPUT_JSON" | grep -o '"input_tokens":[0-9]*' | head -1 | cut -d':' -f2)
output_tokens=$(echo "$INPUT_JSON" | grep -o '"output_tokens":[0-9]*' | head -1 | cut -d':' -f2)
cache_creation=$(echo "$INPUT_JSON" | grep -o '"cache_creation_input_tokens":[0-9]*' | head -1 | cut -d':' -f2)
cache_read=$(echo "$INPUT_JSON" | grep -o '"cache_read_input_tokens":[0-9]*' | head -1 | cut -d':' -f2)

used_tokens=$((${input_tokens:-0} + ${output_tokens:-0} + ${cache_creation:-0} + ${cache_read:-0}))
context_percent=$((used_tokens * 100 / context_size))
remaining_percent=$((100 - context_percent))

# Tokens per minute
tokens_per_min=0
if [ "$duration_ms" -gt 60000 ]; then
    tokens_per_min=$((used_tokens * 60000 / duration_ms))
fi

# Reset time estimate
reset_time_str="N/A"
if [ "$tokens_per_min" -gt 0 ]; then
    remaining_tokens=$((context_size - used_tokens))
    remaining_minutes=$((remaining_tokens / tokens_per_min))
    reset_hours=$((remaining_minutes / 60))
    reset_mins=$((remaining_minutes % 60))
    if [ "$reset_hours" -gt 0 ]; then
        reset_time_str="~${reset_hours}h ${reset_mins}m"
    else
        reset_time_str="~${reset_mins}m"
    fi
fi

# Context color
if [ "$context_percent" -ge 80 ]; then
    context_color=$RED
elif [ "$context_percent" -ge 60 ]; then
    context_color=$YELLOW
elif [ "$context_percent" -ge 40 ]; then
    context_color=$CYAN
else
    context_color=$GREEN
fi

# Progress bar (15 segments)
bar_width=15
filled=$((context_percent * bar_width / 100))
empty=$((bar_width - filled))
progress_bar="[${context_color}"
for ((i=0; i<filled; i++)); do progress_bar+="="; done
progress_bar+="${GRAY}"
for ((i=0; i<empty; i++)); do progress_bar+="-"; done
progress_bar+="${RESET}]"

# Version
version="1.0.0"
script_dir="$(dirname "$0")"
version_file="$script_dir/../VERSION"
[ -f "$version_file" ] && version=$(cat "$version_file" | tr -d '\n\r')

# Weekly stats
weekly_data=$(update_weekly_stats "$cost" "$used_tokens" "$duration_ms")
IFS='|' read -r weekly_cost weekly_tokens weekly_duration weekly_sessions <<< "$weekly_data"
weekly_duration_min=$((${weekly_duration:-0} / 60000))
weekly_hours=$((weekly_duration_min / 60))
weekly_mins=$((weekly_duration_min % 60))
if [ "$weekly_hours" -gt 0 ]; then
    weekly_time_str="${weekly_hours}h${weekly_mins}m"
else
    weekly_time_str="${weekly_mins}m"
fi

# Lines modified
lines_added=$(get_nested_value "cost" "total_lines_added")
lines_removed=$(get_nested_value "cost" "total_lines_removed")
[ -z "$lines_added" ] && lines_added=0
[ -z "$lines_removed" ] && lines_removed=0

# === BUILD OUTPUT ===

# Line 1: Project info
line1="${BLUE}📁 ${BOLD}$display_path${RESET}"
if [ -n "$git_branch" ]; then
    if [ "$git_dirty" = true ]; then
        line1+="  ${YELLOW}🌿 ${git_branch}*${RESET}"
    else
        line1+="  ${GREEN}🌿 ${git_branch}${RESET}"
    fi
fi
line1+="  ${model_color}🤖 $model_full${RESET}"
line1+="  ${GRAY}📟 v$version${RESET}"

# Line 2: Session timing
if [ "$hours" -gt 0 ]; then
    time_str="${hours}h ${minutes}m ${seconds}s"
else
    time_str="${minutes}m ${seconds}s"
fi
line2="${CYAN}⏱️  Session: ${BOLD}$time_str${RESET}"

# Line 3: Context usage
tokens_formatted=$(printf "%'d" "$used_tokens" 2>/dev/null || echo "$used_tokens")
line3="${context_color}🧠 Context: ${BOLD}${context_percent}%${RESET} used / ${GREEN}${remaining_percent}%${RESET} remaining $progress_bar  ${GRAY}⏳ Reset in: $reset_time_str${RESET}"

# Line 4: Cost and tokens
if (( $(echo "$cost > 10" | bc -l 2>/dev/null || echo 0) )); then
    cost_color=$RED
elif (( $(echo "$cost > 5" | bc -l 2>/dev/null || echo 0) )); then
    cost_color=$YELLOW
else
    cost_color=$GREEN
fi

line4="${cost_color}💰 \$$cost_display${RESET}"
if [ "$hourly_rate" != "0" ] && [ -n "$hourly_rate" ]; then
    line4+="  ${DIM}(\$${hourly_rate}/h)${RESET}"
fi
line4+="  ${GRAY}📊 $tokens_formatted tok${RESET}"
if [ "$tokens_per_min" -gt 0 ]; then
    line4+="  ${DIM}(${tokens_per_min} tpm)${RESET}"
fi
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    line4+="  ${GREEN}+$lines_added${RESET}/${RED}-$lines_removed${RESET}"
fi

# Line 5: Weekly stats
weekly_tokens_fmt=$(printf "%'d" "${weekly_tokens:-0}" 2>/dev/null || echo "${weekly_tokens:-0}")
line5="${MAGENTA}📅 This week:${RESET} ${DIM}${weekly_sessions:-0} sessions${RESET}  ${YELLOW}💵 \$${weekly_cost:-0}${RESET}  ${GRAY}🕐 $weekly_time_str${RESET}  ${CYAN}📈 $weekly_tokens_fmt tok${RESET}"

# Output all lines
echo -e "$line1"
echo -e "$line2"
echo -e "$line3"
echo -e "$line4"
echo -e "$line5"
