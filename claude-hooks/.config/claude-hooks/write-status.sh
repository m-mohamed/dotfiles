#!/bin/bash
# write-status.sh - Centralized status writer for Claude Code hooks
# Usage: write-status.sh <status> [attention_type]
#
# Writes status to:
# 1. ~/.cache/claude-status/pane-{id}.json (source of truth for WezTerm plugin)
# 2. OSC 1337 SetUserVar (fast cache for statusbar)
#
# Statuses: idle, working, attention, compacting
# Attention types: permission, input

set -euo pipefail

STATUS="${1:-}"
ATTN_TYPE="${2:-}"

# Ensure cache directory exists first (for debug log)
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-status"
mkdir -p "$CACHE_DIR"

# Debug logging - helps diagnose if hooks are firing
DEBUG_LOG="$CACHE_DIR/debug.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') | status=$STATUS attn=$ATTN_TYPE WEZTERM_PANE=${WEZTERM_PANE:-unset} pwd=$PWD" >> "$DEBUG_LOG"

# Validate status
[[ -z "$STATUS" ]] && exit 0
[[ ! "$STATUS" =~ ^(idle|working|attention|compacting)$ ]] && exit 0

# Get pane ID from WEZTERM_PANE environment variable
# This is set by WezTerm and inherited by subprocesses
PANE_ID="${WEZTERM_PANE:-}"

if [[ -z "$PANE_ID" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') | ERROR: WEZTERM_PANE not set, cannot determine pane ID" >> "$DEBUG_LOG"
  exit 0
fi

# Write status file (source of truth)
if [[ -n "$ATTN_TYPE" ]]; then
  printf '{"status":"%s","attention_type":"%s","project":"%s","start_time":%s,"pane_id":"%s"}' \
    "$STATUS" "$ATTN_TYPE" "${PWD##*/}" "$(date +%s)" "$PANE_ID" > "$CACHE_DIR/pane-$PANE_ID.json"
else
  printf '{"status":"%s","project":"%s","start_time":%s,"pane_id":"%s"}' \
    "$STATUS" "${PWD##*/}" "$(date +%s)" "$PANE_ID" > "$CACHE_DIR/pane-$PANE_ID.json"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') | SUCCESS: wrote $CACHE_DIR/pane-$PANE_ID.json" >> "$DEBUG_LOG"

# Set user var (fast cache for statusbar)
# This may not persist across re-attach due to WezTerm bug #5832, but statusbar
# will fall back to reading the file
printf '\033]1337;SetUserVar=%s=%s\007' claude_status "$(printf '%s' "$STATUS" | base64)"
