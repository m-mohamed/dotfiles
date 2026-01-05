# Claude Agent Plugin - Status Report

## Current State: Partially Working

### What's Working

| Feature | Status | Notes |
|---------|--------|-------|
| **Hooks firing** | ✅ | Claude Code hooks call write-status.sh successfully |
| **Status files created** | ✅ | `~/.cache/claude-status/pane-{id}.json` files exist |
| **Health Check display** | ✅ | Leader+Shift+G shows correct icons for all panes |
| **macOS notifications** | ✅ | terminal-notifier works on Stop/Notification hooks |
| **Multi-workspace detection** | ✅ | CLI correctly finds panes across workspaces |

### What's NOT Working

| Feature | Status | Issue |
|---------|--------|-------|
| **Dashboard icons** | ❌ | Shows white circles (unknown) instead of status colors |
| **User Vars** | ❌ | Always shows "(none)" - OSC 1337 not reaching terminal |
| **Orphan detection** | ❌ | False positive "pane not found" for valid panes |
| **Statusbar** | ❓ | Not verified - may have same issue as dashboard |

---

## Root Cause Analysis

### Issue 1: Dashboard Shows Wrong Status

**Symptom:** Dashboard shows white circles while Health Check shows correct colors.

**Code Paths:**

```
Health Check (diagnostics.lua):
  get_all_status_files()
    → wezterm.read_dir(status_dir)
    → status.read_file(pane_id)  ← Reads file directly
    → Displays correctly ✅

Dashboard (dashboard.lua):
  get_cli_panes()
    → wezterm.run_child_process(wezterm cli list --format json)
    → For each pane: status.read_cached(pane_id)  ← Uses cache
    → Shows unknown ❌
```

**Hypothesis:** `status.read_cached()` may be returning stale/empty cache while `status.read_file()` reads fresh data.

### Issue 2: User Vars Always Empty

**Symptom:** Health Check shows "User Vars: (none)" for all panes.

**Cause:** OSC 1337 escape sequences from hooks don't reach the terminal because hooks run in a subprocess without a TTY connection to WezTerm.

```bash
# In hook subprocess:
printf '\033]1337;SetUserVar=...'  # Goes nowhere - no TTY!
```

**Impact:** User vars were designed as "fast cache" but cannot work from hooks. File-based status is the only reliable source.

### Issue 3: Cleanup Deletes Valid Files (ROOT CAUSE!)

**Symptom:** Status files exist briefly then disappear. Working/idle icons sporadic.

**Root Cause:** `cleanup_stale_files()` is called on every statusbar update:
```lua
-- statusbar.lua line 67
status.cleanup_stale_files()  -- Called on EVERY statusbar refresh!

-- status.lua line 215-216 (inside cleanup)
if pane_id and not current_panes[pane_id] then
    os.remove(filepath)  -- DELETES FILE!
```

**Problem:** `get_cli_pane_ids()` uses `wezterm.run_child_process` which may fail or return empty in certain contexts. When it returns empty, ALL files are treated as orphans and deleted!

**Evidence:**
- Health Check shows "CLI panes: 2, Status files: 2" at one moment
- But "ORPHAN: pane-0.json exists but pane not found"
- Files disappear shortly after creation

**Fix:** Add safety check - don't delete if CLI returned empty:
```lua
local current_panes = get_cli_pane_ids()
-- SAFETY: If CLI failed, don't delete anything
if next(current_panes) == nil then
    wezterm.log_warn("claude-agent: CLI returned no panes, skipping cleanup")
    return
end
```

---

## Code Comparison

### Health Check (WORKS)

```lua
-- diagnostics.lua: get_all_status_files()
local ok, entries = pcall(wezterm.read_dir, status_dir)
for _, filepath in ipairs(entries) do
    local pane_id = filename:match("pane%-(%d+)%.json")
    local data = status.read_file(pane_id)  -- Direct file read
    table.insert(files, { pane_id = tonumber(pane_id), status = data.status, ... })
end
```

### Dashboard (BROKEN)

```lua
-- dashboard.lua: get_agents()
local cli_panes = get_cli_panes()  -- wezterm.run_child_process
for _, cli_pane in ipairs(cli_panes) do
    local status_data = status.read_cached(pane_id)  -- Cached read
    -- status_data may be nil/stale
end
```

---

## Fix Plan

### Fix 1: Dashboard Status Reading

**Option A:** Use `read_file()` instead of `read_cached()` in dashboard
```lua
-- dashboard.lua line 98
local status_data = status.read_file(pane_id)  -- Direct read, not cached
```

**Option B:** Ensure cache is properly cleared before reading
```lua
status.clear_cache()  -- Already called on line 82, but may need more
```

### Fix 2: Remove User Vars Dependency

User vars cannot work from hook subprocesses. Options:
1. Remove user vars code entirely (simplify)
2. Keep as documentation-only feature for manual testing

### Fix 3: Fix Orphan Detection

Debug why `get_cli_pane_ids()` returns empty in diagnostics context:
```lua
-- Add logging
local cli_panes = M.get_cli_panes()
wezterm.log_info("claude-agent: CLI panes count: " .. (next(cli_panes) and "has data" or "EMPTY"))
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Claude Code Hooks                          │
│  (runs in subprocess, no TTY)                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    write-status.sh                              │
│  - Uses $WEZTERM_PANE (inherited env var)                       │
│  - Writes ~/.cache/claude-status/pane-{id}.json                 │
│  - OSC 1337 SetUserVar (DOES NOT WORK - no TTY)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                 Status Files (SOURCE OF TRUTH)                  │
│  ~/.cache/claude-status/pane-0.json                             │
│  ~/.cache/claude-status/pane-1.json                             │
│  ...                                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│   Health Check (✅)      │     │   Dashboard (❌)         │
│   diagnostics.lua       │     │   dashboard.lua         │
│   - read_dir + read_file│     │   - cli list + read_cached │
│   - Shows correct icons │     │   - Shows white circles │
└─────────────────────────┘     └─────────────────────────┘

```

---

## Files Involved

| File | Purpose | Status |
|------|---------|--------|
| `write-status.sh` | Hook script, writes status files | ✅ Working |
| `status.lua` | Status file reading, caching | ⚠️ Cache may be stale |
| `dashboard.lua` | Agent dashboard UI | ❌ Not reading status correctly |
| `diagnostics.lua` | Health check UI | ✅ Working |
| `statusbar.lua` | Tab/status bar display | ❓ Not verified |
| `colors.lua` | Icon/color definitions | ✅ Working |

---

## Next Steps

1. [x] ~~Compare `read_file()` vs `read_cached()` behavior~~ - Not the issue
2. [x] ~~Fix cleanup deleting valid files~~ - Added safety check (2025-01-05)
3. [ ] Test if dashboard icons work consistently now
4. [ ] Fix orphan detection false positive in diagnostics
5. [ ] Consider removing user vars code (dead feature)

## Recent Fixes

### 2025-01-05: Safety check in cleanup_stale_files()

Added check to skip orphan cleanup when CLI returns empty:
```lua
if next(current_panes) == nil then
    wezterm.log_warn("claude-agent: CLI returned no panes, skipping orphan cleanup")
    return
end
```
File: `status.lua` line 202-207
