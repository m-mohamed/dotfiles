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

# Validate status
[[ -z "$STATUS" ]] && exit 0
[[ ! "$STATUS" =~ ^(idle|working|attention|compacting)$ ]] && exit 0

# Get pane ID
PANE_ID="${WEZTERM_PANE:-}"
if [[ -z "$PANE_ID" ]]; then
    exit 0
fi

# Get project name (git repo name or directory name)
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "${PWD##*/}")
TIMESTAMP=$(date +%s)

# Build JSON payload
if [[ -n "$ATTN_TYPE" ]]; then
    JSON=$(printf '{"event":"%s","status":"%s","attention_type":"%s","pane_id":"%s","project":"%s","timestamp":%s}' \
        "$HOOK_NAME" "$STATUS" "$ATTN_TYPE" "$PANE_ID" "$PROJECT" "$TIMESTAMP")
else
    JSON=$(printf '{"event":"%s","status":"%s","pane_id":"%s","project":"%s","timestamp":%s}' \
        "$HOOK_NAME" "$STATUS" "$PANE_ID" "$PROJECT" "$TIMESTAMP")
fi

# Always write file for WezTerm plugin (file-based architecture)
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-status"
mkdir -p "$CACHE_DIR"

if [[ -n "$ATTN_TYPE" ]]; then
    printf '{"status":"%s","attention_type":"%s","project":"%s","start_time":%s,"pane_id":"%s"}' \
        "$STATUS" "$ATTN_TYPE" "$PROJECT" "$TIMESTAMP" "$PANE_ID" > "$CACHE_DIR/pane-$PANE_ID.json"
else
    printf '{"status":"%s","project":"%s","start_time":%s,"pane_id":"%s"}' \
        "$STATUS" "$PROJECT" "$TIMESTAMP" "$PANE_ID" > "$CACHE_DIR/pane-$PANE_ID.json"
fi

# Also send to socket for Rust TUI (real-time architecture, no fallback)
if [[ -S "$SOCKET" ]]; then
    python3 -c "
import socket
import sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    s.connect('$SOCKET')
    s.sendall(b'$JSON\n')
    s.close()
except:
    pass  # Socket send is fire-and-forget, TUI handles its own state
" 2>/dev/null
fi
