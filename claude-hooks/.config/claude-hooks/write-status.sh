#!/bin/bash
# write-status.sh - Centralized status writer for Claude Code hooks
# Usage: write-status.sh <status> [attention_type] [hook_name]
#
# Writes status to:
# 1. ~/.cache/claude-status/pane-{id}.json (source of truth for WezTerm plugin)
# 2. OSC 1337 SetUserVar (fast cache for statusbar)
#
# Statuses: idle, working, attention, compacting
# Attention types: permission, input
# Hook names: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse,
#             PermissionRequest, Notification, Stop, SubagentStop, PreCompact, SessionEnd

set -euo pipefail

STATUS="${1:-}"
ATTN_TYPE="${2:-}"
HOOK_NAME="${3:-unknown}"

# Ensure cache directory exists first (for debug log)
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-status"
mkdir -p "$CACHE_DIR"

DEBUG_LOG="$CACHE_DIR/debug.log"
PANE_ID="${WEZTERM_PANE:-}"
STATUS_FILE="$CACHE_DIR/pane-$PANE_ID.json"

# Log rotation: keep last 1000 lines (run occasionally)
if [[ -f "$DEBUG_LOG" ]] && (( $(wc -l < "$DEBUG_LOG") > 2000 )); then
  tail -1000 "$DEBUG_LOG" > "$DEBUG_LOG.tmp" && mv "$DEBUG_LOG.tmp" "$DEBUG_LOG"
fi

# Get previous status for transition tracking
PREV_STATUS="none"
if [[ -n "$PANE_ID" ]] && [[ -f "$STATUS_FILE" ]]; then
  PREV_STATUS=$(grep -o '"status":"[^"]*"' "$STATUS_FILE" 2>/dev/null | cut -d'"' -f4 || echo "none")
fi

# Session marker for fresh sessions
SESSION_MARKER=""
if [[ "$HOOK_NAME" == "SessionStart" ]]; then
  SESSION_MARKER=" [NEW SESSION]"
fi

# Enhanced debug logging with hook name and transition
echo "$(date '+%Y-%m-%d %H:%M:%S') | hook=${HOOK_NAME} ${PREV_STATUS}→${STATUS} attn=${ATTN_TYPE} pane=${PANE_ID:-unset} project=${PWD##*/}${SESSION_MARKER}" >> "$DEBUG_LOG"

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

# Success is implicit if we reach here without error

# Set user var (fast cache for statusbar)
# This may not persist across re-attach due to WezTerm bug #5832, but statusbar
# will fall back to reading the file
printf '\033]1337;SetUserVar=%s=%s\007' claude_status "$(printf '%s' "$STATUS" | base64)"
