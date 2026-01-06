# Claude Agent Plugin - Status Report

## Current State: Working

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Hooks firing** | ✅ | All 8 hooks configured (SessionStart, UserPromptSubmit, PermissionRequest, Notification, Stop, PostToolUse, SubagentStop, SessionEnd) |
| **Status files** | ✅ | `~/.cache/claude-status/pane-{id}.json` written reliably |
| **Dashboard (Leader+G)** | ✅ | Shows all agents with colored status icons |
| **Health Check (Leader+Shift+G)** | ✅ | Shows status files and diagnostics |
| **macOS notifications** | ✅ | terminal-notifier on Stop/Notification/PermissionRequest |
| **Multi-workspace** | ✅ | Works across all workspaces |
| **Debug logging** | ✅ | `~/.cache/claude-status/debug.log` |

### Known Limitations

| Feature | Status | Notes |
|---------|--------|-------|
| **User Vars** | ⚠️ | OSC 1337 doesn't work from hook subprocesses (no TTY) |
| **Orphan detection** | ⚠️ | CLI unreliable in callback contexts - detection skipped when data incomplete |

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
             PostToolUse          [Claude thinking]
             (stays working)            │
                    │                   │
                    └─────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
       PermissionRequest  Notification     Stop
       → attention        → attention    → idle
       (permission)       (input)
                              │
        SubagentStop ─────────┼──────────────→ working
        (back from agent)     │
                              │
        SessionEnd ───────────┼──────────────→ cleanup
        (removes status file)
```

### States

| State | Icon | Color | When |
|-------|------|-------|------|
| `attention` | 🔔 | Orange | Needs user input or permission |
| `working` | 🤖 | Blue | Claude actively processing |
| `idle` | ⏸️ | Gray | Session inactive, waiting for prompt |
| `unknown` | ⚪ | White | No status file found |

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
| `write-status.sh` | Hook script - writes status JSON |
| `status.lua` | Status file reading, caching, cleanup |
| `dashboard.lua` | Agent dashboard UI (Leader+G) |
| `diagnostics.lua` | Health check UI (Leader+Shift+G) |
| `statusbar.lua` | Status bar segment |
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
