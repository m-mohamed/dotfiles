-- claude-agent/status.lua - Status reading, caching, and event emission
local wezterm = require("wezterm")
local M = {}

-- Cache state version (increment if schema changes)
local CACHE_VERSION = 1
local MAX_CACHE_SIZE = 100 -- Maximum cached panes

-- Default options (can be overridden via setup)
M.options = {
	status_dir = os.getenv("HOME") .. "/.cache/claude-status",
	cache_ttl = 1, -- seconds
	stale_threshold = 3600, -- 1 hour
	cleanup_interval = 300, -- 5 minutes
}

-- Get or initialize cache from wezterm.GLOBAL
local function get_state()
	local state = wezterm.GLOBAL.claude_agent

	-- Initialize or reset if version mismatch
	if not state or state.version ~= CACHE_VERSION then
		wezterm.GLOBAL.claude_agent = {
			version = CACHE_VERSION,
			cache = {},
			cache_order = {}, -- Track insertion order for LRU
			last_cleanup = 0,
		}
		state = wezterm.GLOBAL.claude_agent
	end

	return state
end

-- Evict oldest cache entries when over limit
local function evict_old_cache_entries(state)
	while #state.cache_order > MAX_CACHE_SIZE do
		local oldest_id = table.remove(state.cache_order, 1)
		state.cache[oldest_id] = nil
	end
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
	local state = get_state()
	local cache = state.cache
	local now = os.time()
	local entry = cache[pane_id]

	-- Return cached if fresh
	if entry and (now - entry.time) < M.options.cache_ttl then
		return entry.data
	end

	-- Read fresh
	local data = M.read_file(pane_id)
	local old_status = entry and entry.data and entry.data.status
	local new_status = data and data.status

	-- Emit events on status change
	if old_status ~= new_status then
		wezterm.emit("claude-agent.status.changed", pane_id, old_status, new_status)
		if new_status == "blocked" or new_status == "waiting" then
			wezterm.emit("claude-agent.status.blocked", pane_id, data)
		end
	end

	-- Update cache with LRU tracking
	if not entry then
		-- New entry - add to order tracking
		table.insert(state.cache_order, pane_id)
		evict_old_cache_entries(state)
	end
	cache[pane_id] = { data = data, time = now }

	return data
end

-- Get all current pane IDs
M.get_current_pane_ids = function()
	local pane_ids = {}
	local all_windows = wezterm.mux.all_windows()
	if not all_windows then
		return pane_ids
	end
	for _, mux_win in ipairs(all_windows) do
		local tabs = mux_win:tabs()
		if tabs then
			for _, tab in ipairs(tabs) do
				local panes = tab:panes()
				if panes then
					for _, pane in ipairs(panes) do
						pane_ids[tostring(pane:pane_id())] = true
					end
				end
			end
		end
	end
	return pane_ids
end

-- Clean up stale and orphaned status files
M.cleanup_stale_files = function()
	local state = get_state()
	local now = os.time()

	-- Only run cleanup periodically
	if now - state.last_cleanup < M.options.cleanup_interval then
		return
	end
	state.last_cleanup = now

	-- Get current pane IDs for orphan detection
	local current_panes = M.get_current_pane_ids()

	-- Read directory and remove orphaned files
	-- Validate status_dir path (prevent shell injection)
	local status_dir = M.options.status_dir
	if not status_dir or status_dir:match("[;&|`$]") then
		wezterm.log_warn("claude-agent: Invalid status_dir path, skipping cleanup")
		return
	end

	local handle = io.popen('ls "' .. status_dir .. '" 2>/dev/null')
	if handle then
		for file in handle:lines() do
			local pane_id = file:match("pane%-(%d+)%.json")
			if pane_id and not current_panes[pane_id] then
				os.remove(M.options.status_dir .. "/" .. file)
			end
		end
		handle:close()
	end

	-- Also clean files older than threshold
	wezterm.background_child_process({
		"zsh",
		"-c",
		string.format(
			[[find %s -name "pane-*.json" -type f -mmin +%d -delete 2>/dev/null]],
			M.options.status_dir,
			math.floor(M.options.stale_threshold / 60)
		),
	})
end

-- Count agents by status across all panes in a mux window
M.count_agents = function(mux_window)
	local counts = { running = 0, blocked = 0, waiting = 0, idle = 0 }
	for _, tab in ipairs(mux_window:tabs()) do
		for _, pane in ipairs(tab:panes()) do
			local data = M.read_cached(pane:pane_id())
			local status = data and data.status
			if status and counts[status] ~= nil then
				counts[status] = counts[status] + 1
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

return M
