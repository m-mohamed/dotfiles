-- claude-agent/analytics.lua - Analytics and logging for debugging/monitoring
-- Pattern: File-based logging with status transitions for verifying plugin behavior
local wezterm = require("wezterm")
local M = {}

-- Default options
M.options = {
	enabled = true,
	log_status = true, -- Log status transitions
	log_dashboard = true, -- Log dashboard interactions
	log_errors = true, -- Log errors
	log_path = nil, -- Will be computed in setup()
	max_file_size = 1048576, -- 1MB before rotation
}

-- Get XDG-compliant default log path
local function get_default_log_path()
	local xdg = os.getenv("XDG_CACHE_HOME")
	local cache_dir = (xdg and xdg ~= "" and xdg or os.getenv("HOME") .. "/.cache")
	return cache_dir .. "/claude-status/analytics.log"
end

-- Format timestamp as ISO 8601
local function timestamp()
	return os.date("%Y-%m-%d %H:%M:%S")
end

-- Ensure log directory exists
local function ensure_dir()
	local dir = M.options.log_path:match("(.+)/[^/]+$")
	-- Validate path (prevent shell injection)
	if dir and not dir:match("[;&|`$]") then
		os.execute('mkdir -p "' .. dir .. '" 2>/dev/null')
	end
end

-- Check file size and rotate if needed
local function maybe_rotate()
	local f = io.open(M.options.log_path, "r")
	if f then
		local size = f:seek("end")
		f:close()
		if size and size > M.options.max_file_size then
			local backup = M.options.log_path .. ".1"
			os.remove(backup)
			os.rename(M.options.log_path, backup)
			wezterm.log_info("claude-agent: Rotated analytics log")
		end
	end
end

-- Write a log entry
local function write_log(event_type, fields)
	if not M.options.enabled then
		return
	end

	-- Build field string (sorted keys for consistency)
	local keys = {}
	for k in pairs(fields) do
		table.insert(keys, k)
	end
	table.sort(keys)

	local parts = {}
	for _, k in ipairs(keys) do
		local v = fields[k]
		if v ~= nil then
			table.insert(parts, string.format("%s=%s", k, tostring(v)))
		end
	end
	local field_str = table.concat(parts, " ")

	-- Build full log line
	local line = string.format("%s [%s] %s\n", timestamp(), event_type, field_str)

	-- Rotate if needed
	maybe_rotate()

	-- Ensure directory exists
	ensure_dir()

	-- Append to log file
	local f = io.open(M.options.log_path, "a")
	if f then
		f:write(line)
		f:close()
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
	-- Set default log path if not specified
	if not M.options.log_path then
		M.options.log_path = get_default_log_path()
	end
end

-- Log status transition
M.log_status = function(pane_id, old_status, new_status, project)
	if not M.options.log_status then
		return
	end
	write_log("STATUS", {
		pane = pane_id,
		transition = string.format("%s->%s", old_status or "nil", new_status or "nil"),
		project = project or "unknown",
	})
end

-- Log dashboard action
M.log_dashboard = function(action, details)
	if not M.options.log_dashboard then
		return
	end
	details = details or {}
	details.action = action
	write_log("DASHBOARD", details)
end

-- Log error
M.log_error = function(source, message)
	if not M.options.log_errors then
		return
	end
	-- Escape quotes in message
	local escaped_msg = tostring(message):gsub('"', '\\"'):gsub("\n", " ")
	write_log("ERROR", {
		source = source,
		msg = string.format('"%s"', escaped_msg),
	})
end

-- Log plugin ready
M.log_ready = function(options)
	write_log("READY", {
		status_dir = options.status_dir or "default",
		cache_ttl = options.cache_ttl or 1,
		analytics = "enabled",
	})
end

-- Register event listeners for all plugin events
M.register_events = function()
	-- Status changed (key event for debugging!)
	wezterm.on("claude-agent.status.changed", function(pane_id, old_status, new_status)
		-- Try to get project from status module
		local ok, status_mod = pcall(require, "claude-agent.status")
		local project = nil
		if ok then
			local data = status_mod.read_file(pane_id)
			project = data and data.project
		end
		M.log_status(pane_id, old_status, new_status, project)
	end)

	-- Dashboard opened
	wezterm.on("claude-agent.dashboard.opened", function(window, total, counts)
		M.log_dashboard("opened", {
			agents = total,
			working = counts.working or 0,
			attention = counts.attention or 0,
			idle = counts.idle or 0,
		})
	end)

	-- Dashboard selection
	wezterm.on("claude-agent.dashboard.selected", function(window, pane_id)
		M.log_dashboard("selected", { pane = pane_id })
	end)

	-- Dashboard canceled
	wezterm.on("claude-agent.dashboard.canceled", function(window)
		M.log_dashboard("canceled", {})
	end)

	-- Error
	wezterm.on("claude-agent.error", function(source, message)
		M.log_error(source, message)
	end)

	-- Plugin ready
	wezterm.on("claude-agent.ready", function(options)
		M.log_ready(options)
	end)

	wezterm.log_info("claude-agent: Analytics event handlers registered")
end

-- Get log file path (for external tools)
M.get_log_path = function()
	return M.options.log_path or get_default_log_path()
end

-- Get log file size in bytes
M.get_log_size = function()
	local path = M.get_log_path()
	local f = io.open(path, "r")
	if f then
		local size = f:seek("end")
		f:close()
		return size or 0
	end
	return 0
end

-- Clear log file
M.clear_log = function()
	local path = M.get_log_path()
	local f = io.open(path, "w")
	if f then
		f:close()
		wezterm.log_info("claude-agent: Analytics log cleared")
		return true
	end
	return false
end

return M
