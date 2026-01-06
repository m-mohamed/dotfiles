# Claude Agent Plugin - Status Report

## Current State: Working (4-State System)

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Hooks firing** | ✅ | All 10 hooks configured (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PermissionRequest, Notification, Stop, SubagentStop, PreCompact, SessionEnd) |
| **Status files** | ✅ | `~/.cache/claude-status/pane-{id}.json` written reliably |
| **Dashboard (Leader+G)** | ✅ | Shows all agents with colored status icons |
| **Health Check (Leader+Shift+G)** | ✅ | Shows status files and diagnostics |
| **macOS notifications** | ✅ | terminal-notifier on PermissionRequest + Stop |
| **Multi-workspace** | ✅ | Works across all workspaces |
| **Debug logging** | ✅ | `~/.cache/claude-status/debug.log` |

### Known Limitations

| Feature | Status | Notes |
|---------|--------|-------|
| **User Vars** | ⚠️ | OSC 1337 doesn't work from hook subprocesses (no TTY) |
| **Orphan detection** | ⚠️ | CLI unreliable in callback contexts - detection skipped when data incomplete |
| **PermissionRequest** | ⚠️ | Undocumented hook, but working - keep monitoring |

---

## Hook Event Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Session                       │
└─────────────────────────────────────────────────────────────┘
                              │
        SessionStart ─────────┼──────────────→ idle
                              │
        UserPromptSubmit ─────┼──────────────→ working
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
             PreToolUse           [Claude thinking]
             PostToolUse                │
             (stays working)            │
                    │                   │
                    └─────────┬─────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
 PermissionRequest      Notification          PreCompact
 → attention            → attention           → compacting
 (permission)           (input)               (context full)
                              │
        SubagentStop ─────────┼──────────────→ working
        (back from agent)     │
                              │
        Stop ─────────────────┼──────────────→ idle
                              │
        SessionEnd ───────────┼──────────────→ cleanup
        (removes status file)
```

### 4-State System

| State | Icon | Color | Meaning | Hooks |
|-------|------|-------|---------|-------|
| `idle` | ⏸️ | Gray (#565f89) | Waiting for prompt | SessionStart, Stop |
| `working` | 🤖 | Blue (#7aa2f7) | Processing | UserPromptSubmit, PreToolUse, PostToolUse, SubagentStop |
| `attention` | 🔔 | Orange (#ff9e64) | Needs user action | PermissionRequest, Notification |
| `compacting` | 🔄 | Yellow (#e0af68) | Context filling up | PreCompact |
| `unknown` | ⚪ | White | No status file found | - |

---

## Architecture

```
Claude Code Hooks → write-status.sh → pane-{id}.json
                                          ↓
                    ┌─────────────────────┴─────────────────────┐
                    ▼                                           ▼
              Dashboard (Leader+G)                    Health Check (Leader+Shift+G)
              wezterm.read_dir() ✅                   wezterm.read_dir() ✅
              CLI for metadata only                   CLI for orphan detection
```

### Files

| File | Purpose |
|------|---------|
| `send-event.sh` | Bridge script - writes status JSON + sends to socket |
| `status.lua` | Status file reading, caching, cleanup |
| `dashboard.lua` | Agent dashboard UI (Leader+G) |
| `diagnostics.lua` | Health check UI (Leader+Shift+G) |
| `statusbar.lua` | Status bar segment (DISABLED - kept for reference) |
| `colors.lua` | Icon/color definitions |

---

## Debugging

### Check hook activity
```bash
tail -f ~/.cache/claude-status/debug.log
```

### View status files
```bash
cat ~/.cache/claude-status/*.json | jq .
```

### Check CLI pane enumeration
```bash
/opt/homebrew/bin/wezterm cli list --format json | jq '.[].pane_id'
```

---

## Recent Fixes

### 2026-01-06: End-to-End Audit Improvements

**Bridge Layer (send-event.sh):**
- Fixed JSON escaping vulnerability - now uses `jq` for proper escaping
- Fixed Python code injection - JSON passed via stdin, not shell substitution
- Added logging when WEZTERM_PANE is unset (was silent failure)
- Added socket timeout (500ms) to prevent hanging

**WezTerm Plugin:**
- Added JSON schema validation - rejects invalid status values
- Fixed cache clearing - removed aggressive clear_cache() that defeated LRU
- Documented statusbar.lua as disabled

**Rust TUI:**
- Added connection limiting (100 max) via semaphore
- Added exponential backoff on socket accept errors
- Prevents CPU spin and memory exhaustion under load

### 2026-01-05: Notification noise reduction + Startup cleanup
- Kept "Claude Done" notification (Stop hook) - useful when multitasking
- Removed "Claude Waiting" notification (Notification hook) - redundant when focused
- Removed "Context Compacting" notification (PreCompact) - status bar shows state
- Kept "Permission Needed" notification (PermissionRequest) - important alert
- Fixed startup cleanup delay: orphan files now cleaned immediately on WezTerm start

### 2026-01-05: 4-State System Upgrade

Upgraded from 3-state to 4-state system:
- **New state**: `compacting` (🔄 yellow) for context compaction
- **New hook**: `PreCompact` fires when context is about to compact
- **Notification**: macOS notification with "Purr" sound when compacting starts
- **Total hooks**: 10 (9 official + PermissionRequest undocumented)

### 2026-01-05: Enhanced hook coverage

Added 3 new hooks for better observability:
- **PostToolUse**: Keeps "working" visible during tool execution
- **SubagentStop**: Shows "working" when returning from Task agents
- **SessionEnd**: Cleans up status file when session closes

### 2026-01-05: Health Check orphan detection fix

Changed orphan detection to skip when CLI returns incomplete data:
- If CLI returns 0 panes → skip (CLI failure)
- If CLI returns fewer panes than status files → warn (possible CLI failure)
- Only flag orphans when CLI data is reliable

### 2026-01-05: Dashboard filesystem scan

Changed `get_agents()` to use filesystem scan as primary source:
- **Before**: CLI enumeration → may miss panes when CLI fails
- **After**: Filesystem scan → finds ALL status files reliably

### 2026-01-05: Safety check in cleanup

Added check to skip cleanup when CLI returns empty to prevent deleting valid files.
