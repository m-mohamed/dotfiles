#!/bin/bash
# send-event.sh - Send hook events to claude-observer daemon
#
# Usage: send-event.sh <status> [attention_type] [hook_name]
#
# This script sends events to the claude-observer Unix socket.
# Falls back to file-based approach if daemon is not running.
#
# Environment:
#   WEZTERM_PANE - Pane ID (set by WezTerm)
#   CLAUDE_OBSERVER_SOCKET - Socket path (default: /tmp/claude-observer.sock)

set -euo pipefail

STATUS="${1:-}"
ATTN_TYPE="${2:-}"
HOOK_NAME="${3:-unknown}"
SOCKET="${CLAUDE_OBSERVER_SOCKET:-/tmp/claude-observer.sock}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-status"
DEBUG_LOG="$CACHE_DIR/debug.log"

# Validate status
[[ -z "$STATUS" ]] && exit 0
[[ ! "$STATUS" =~ ^(idle|working|attention|compacting)$ ]] && exit 0

# Get pane ID
PANE_ID="${WEZTERM_PANE:-}"
if [[ -z "$PANE_ID" ]]; then
    # Log missing pane ID for debugging
    mkdir -p "$CACHE_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ERROR: WEZTERM_PANE not set (hook=$HOOK_NAME status=$STATUS)" >> "$DEBUG_LOG"
    exit 0
fi

# Get project name (git repo name or directory name)
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null) || PROJECT="${PWD##*/}" || PROJECT="unknown"
TIMESTAMP=$(date +%s)

# Build JSON payloads using jq for proper escaping
# This prevents JSON injection from project names with quotes/special chars
JSON_SOCKET=$(jq -n \
    --arg event "$HOOK_NAME" \
    --arg status "$STATUS" \
    --arg attention_type "$ATTN_TYPE" \
    --arg pane_id "$PANE_ID" \
    --arg project "$PROJECT" \
    --argjson timestamp "$TIMESTAMP" \
    '{event: $event, status: $status, attention_type: $attention_type, pane_id: $pane_id, project: $project, timestamp: $timestamp}')

JSON_FILE=$(jq -n \
    --arg status "$STATUS" \
    --arg attention_type "$ATTN_TYPE" \
    --arg project "$PROJECT" \
    --argjson start_time "$TIMESTAMP" \
    --arg pane_id "$PANE_ID" \
    '{status: $status, attention_type: $attention_type, project: $project, start_time: $start_time, pane_id: $pane_id}')

# Always write file for WezTerm plugin (file-based architecture)
mkdir -p "$CACHE_DIR"
printf '%s' "$JSON_FILE" > "$CACHE_DIR/pane-$PANE_ID.json"

# Also send to socket for Rust TUI (real-time architecture, no fallback)
if [[ -S "$SOCKET" ]]; then
    # Use Python with stdin to avoid shell injection in the JSON
    printf '%s\n' "$JSON_SOCKET" | python3 -c "
import socket
import sys

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(0.5)  # 500ms timeout to prevent hanging
try:
    s.connect('$SOCKET')
    data = sys.stdin.read()
    s.sendall(data.encode())
    s.close()
except (TimeoutError, BrokenPipeError, ConnectionRefusedError, OSError):
    pass  # Socket send is fire-and-forget, TUI handles its own state
" 2>/dev/null
fi
