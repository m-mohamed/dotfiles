-- claude-agent/status.lua - Status reading, caching, and event emission
local wezterm = require("wezterm")
local M = {}

-- Cache configuration
local MAX_CACHE_SIZE = 100 -- Maximum cached panes

-- Module-local cache state (wezterm.GLOBAL doesn't support nested tables with integer keys)
local cache = {}
local cache_order = {}
local last_cleanup = 0 -- Allow first cleanup to run immediately on startup

-- Default cache directory (respects XDG_CACHE_HOME) - exported for init.lua
M.get_default_dir = function()
	local xdg = os.getenv("XDG_CACHE_HOME")
	return (xdg and xdg ~= "" and xdg or os.getenv("HOME") .. "/.cache") .. "/claude-status"
end

-- Default options (can be overridden via setup)
M.options = {
	status_dir = M.get_default_dir(),
	cache_ttl = 1, -- seconds
	stale_threshold = 3600, -- 1 hour
	cleanup_interval = 300, -- 5 minutes
}

-- Evict oldest cache entries when over limit
local function evict_old_cache_entries()
	while #cache_order > MAX_CACHE_SIZE do
		local oldest_id = table.remove(cache_order, 1)
		cache[oldest_id] = nil
	end
end

-- Clear entire cache (call before dashboard to ensure fresh reads)
-- Needed because pane IDs are unstable with Unix domains
M.clear_cache = function()
	cache = {}
	cache_order = {}
end

-- Detect wezterm CLI path (same as dashboard.lua)
local function find_wezterm_cli()
	local paths = {
		"/opt/homebrew/bin/wezterm",
		"/usr/local/bin/wezterm",
		"/usr/bin/wezterm",
	}
	for _, path in ipairs(paths) do
		local f = io.open(path, "r")
		if f then
			f:close()
			return path
		end
	end
	return "wezterm"
end

local WEZTERM_CLI = find_wezterm_cli()

-- Get full pane data from CLI (exported for dashboard.lua)
-- Returns array: [{pane_id, tab_id, workspace, title, cwd, ...}, ...]
-- Returns nil on error
-- NOTE: Uses run_child_process (not io.popen) to avoid blocking GUI thread
M.get_cli_panes = function()
	local success, stdout, stderr = wezterm.run_child_process({ WEZTERM_CLI, "cli", "list", "--format", "json" })
	if not success then
		wezterm.log_warn("claude-agent: Failed to run wezterm cli list: " .. (stderr or "unknown error"))
		return nil
	end

	if not stdout or stdout == "" then
		return nil
	end

	local ok, panes = pcall(wezterm.json_parse, stdout)
	if not ok or type(panes) ~= "table" then
		wezterm.log_warn("claude-agent: Failed to parse wezterm cli list output")
		return nil
	end

	return panes
end

-- Get pane IDs from CLI (matches $WEZTERM_PANE, unlike Lua pane:pane_id())
-- Returns a set table { ["0"] = true, ["1"] = true, ... }
local function get_cli_pane_ids()
	local panes = M.get_cli_panes()
	local pane_ids = {}

	if panes then
		for _, pane in ipairs(panes) do
			if pane.pane_id then
				pane_ids[tostring(pane.pane_id)] = true
			end
		end
	end

	return pane_ids
end

-- Setup with user options
M.setup = function(opts)
	if opts then
		for k, v in pairs(opts) do
			if M.options[k] ~= nil then
				M.options[k] = v
			end
		end
	end
end

-- Read status from user vars (instant, set via OSC 1337)
-- Returns status string ("working", "attention", "idle") or nil
M.read_user_var = function(pane)
	if not pane then
		return nil
	end
	local ok, user_vars = pcall(function()
		return pane:get_user_vars()
	end)
	if ok and user_vars and user_vars.claude_status then
		return user_vars.claude_status
	end
	return nil
end

-- Read status from file (raw, no caching)
M.read_file = function(pane_id)
	local path = M.options.status_dir .. "/pane-" .. tostring(pane_id) .. ".json"

	local f = io.open(path, "r")
	if not f then
		return nil
	end

	local content = f:read("*a")
	f:close()

	if not content or content == "" then
		return nil
	end

	local ok, data = pcall(wezterm.json_parse, content)
	if not ok then
		wezterm.log_warn("claude-agent: Failed to parse status JSON for pane " .. tostring(pane_id))
		return nil
	end
	if type(data) ~= "table" or not data.status then
		return nil
	end

	return data
end

-- Read status with caching and event emission
M.read_cached = function(pane_id)
	local now = os.time()
	local key = tostring(pane_id)
	local entry = cache[key]

	-- Return cached if fresh AND data exists (don't cache stale data when files change)
	if entry and (now - entry.time) < M.options.cache_ttl then
		-- If we have cached data, verify file still exists before returning
		if entry.data then
			return entry.data
		end
		-- If cached nil, always re-read (files might have been created)
	end

	-- Read fresh (always re-read when cache has nil or is stale)
	local data = M.read_file(pane_id)
	local old_status = entry and entry.data and entry.data.status
	local new_status = data and data.status

	-- Emit events on status change
	if old_status ~= new_status then
		wezterm.emit("claude-agent.status.changed", pane_id, old_status, new_status)
		if new_status == "attention" then
			wezterm.emit("claude-agent.status.blocked", pane_id, data)
		end
	end

	-- Update cache with LRU tracking
	if not entry then
		-- New entry - add to order tracking
		table.insert(cache_order, key)
		evict_old_cache_entries()
	end
	cache[key] = { data = data, time = now }

	return data
end

-- Get all current pane IDs (uses CLI for correct IDs that match $WEZTERM_PANE)
M.get_current_pane_ids = function()
	-- Use CLI to get correct pane IDs (mux pane:pane_id() returns different values)
	return get_cli_pane_ids()
end

-- Clean up stale and orphaned status files
M.cleanup_stale_files = function()
	local now = os.time()

	-- Only run cleanup periodically
	if now - last_cleanup < M.options.cleanup_interval then
		return
	end
	last_cleanup = now

	-- Get current pane IDs from CLI (matches $WEZTERM_PANE used in status filenames)
	local current_panes = get_cli_pane_ids()

	-- SAFETY: If CLI returned empty, don't delete anything
	-- This prevents deleting valid files when run_child_process fails
	if next(current_panes) == nil then
		wezterm.log_warn("claude-agent: CLI returned no panes, skipping orphan cleanup")
		return
	end

	-- Read directory and remove orphaned files using wezterm.read_dir (no subprocess)
	local status_dir = M.options.status_dir
	if not status_dir then
		wezterm.log_warn("claude-agent: Invalid status_dir path, skipping cleanup")
		return
	end

	local ok, files = pcall(wezterm.read_dir, status_dir)
	if ok and files then
		for _, filepath in ipairs(files) do
			local file = filepath:match("([^/]+)$") -- Extract filename from path
			if file then
				local pane_id = file:match("pane%-(%d+)%.json")
				if pane_id and not current_panes[pane_id] then
					os.remove(filepath)
				end
			end
		end
	end

	-- Also clean files older than threshold (reuse validated status_dir)
	wezterm.background_child_process({
		"zsh",
		"-c",
		string.format(
			[[find "%s" -name "pane-*.json" -type f -mmin +%d -delete 2>/dev/null]],
			status_dir,
			math.floor(M.options.stale_threshold / 60)
		),
	})
end

-- Count agents by status using CLI enumeration + file-based status
-- This works because:
-- 1. CLI gives us real pane IDs ($WEZTERM_PANE values)
-- 2. Status files are keyed by CLI pane ID
-- 3. No mux ID vs CLI ID mismatch
-- 4-state system: working, compacting, attention, idle
M.count_agents = function(mux_window)
	-- mux_window is unused but kept for API compatibility
	local counts = { working = 0, compacting = 0, attention = 0, idle = 0 }

	-- Use CLI to get pane IDs (same approach as dashboard)
	local cli_panes = M.get_cli_panes()
	if not cli_panes then
		return counts
	end

	-- Read status files using CLI pane IDs
	for _, cli_pane in ipairs(cli_panes) do
		local status_data = M.read_file(cli_pane.pane_id)
		if status_data and status_data.status then
			if counts[status_data.status] then
				counts[status_data.status] = counts[status_data.status] + 1
			end
		end
	end

	return counts
end

-- Format elapsed time from start_time
M.format_elapsed = function(start_time)
	if not start_time then
		return nil
	end
	local start = tonumber(start_time)
	if not start then
		return nil
	end
	local elapsed = os.time() - start
	if elapsed < 60 then
		return string.format("%ds", elapsed)
	elseif elapsed < 3600 then
		return string.format("%dm", math.floor(elapsed / 60))
	else
		return string.format("%dh", math.floor(elapsed / 3600))
	end
end

-- Validation helpers for diagnostics

-- Validate that file status matches user_var status
-- Returns nil if valid, or mismatch info if invalid
M.validate_status = function(pane_id, pane)
	local file_data = M.read_file(pane_id)
	local user_var = M.read_user_var(pane)

	-- If neither exists, that's fine
	if not file_data and not user_var then
		return nil
	end

	-- If only one exists, that's a mismatch
	if file_data and not user_var then
		return {
			pane_id = pane_id,
			file_status = file_data.status,
			user_var_status = nil,
			reason = "file_only",
		}
	end

	if user_var and not file_data then
		return {
			pane_id = pane_id,
			file_status = nil,
			user_var_status = user_var,
			reason = "user_var_only",
		}
	end

	-- Both exist - check if they match
	if file_data.status ~= user_var then
		return {
			pane_id = pane_id,
			file_status = file_data.status,
			user_var_status = user_var,
			reason = "status_mismatch",
		}
	end

	return nil -- Valid
end

-- Get all status files (for diagnostics)
M.get_all_status_files = function()
	local files = {}
	local ok, entries = pcall(wezterm.read_dir, M.options.status_dir)
	if not ok or not entries then
		return files
	end

	for _, filepath in ipairs(entries) do
		local filename = filepath:match("([^/]+)$")
		if filename then
			local pane_id = filename:match("pane%-(%d+)%.json")
			if pane_id then
				table.insert(files, {
					pane_id = tonumber(pane_id),
					filename = filename,
					path = filepath,
				})
			end
		end
	end

	return files
end

return M
