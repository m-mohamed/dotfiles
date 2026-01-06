-- claude-agent/init.lua - Multi-agent monitoring for Claude Code
-- Pattern: tabline.wez / smart_workspace_switcher.wezterm
--
-- Events emitted by this plugin (for extensibility):
--   claude-agent.ready              - Plugin initialized, receives (options)
--   claude-agent.refresh            - Manual refresh triggered, receives (window)
--   claude-agent.status.changed     - Agent status changed, receives (pane_id, old_status, new_status)
--   claude-agent.status.blocked     - Agent needs attention, receives (pane_id, status_data)
--   claude-agent.dashboard.opened   - Dashboard opened, receives (window, agent_count, counts_table)
--   claude-agent.dashboard.selected - Agent selected in dashboard, receives (window, pane_id)
--   claude-agent.dashboard.canceled - Dashboard closed without selection, receives (window)
--   claude-agent.health_check       - Health check run, receives (window, results)
--   claude-agent.error              - Error occurred, receives (source, error_message)
--
-- Keybindings:
--   Leader + G       - Open agent dashboard
--   Leader + N       - Jump to next agent needing attention
--   Leader + Shift+G - Open health check overlay
--
local wezterm = require("wezterm")
local M = {}

-- Lazy load submodules
M.colors = require("claude-agent.colors")
M.status = require("claude-agent.status")
M.statusbar = require("claude-agent.statusbar")
M.dashboard = require("claude-agent.dashboard")
M.analytics = require("claude-agent.analytics")
M.diagnostics = require("claude-agent.diagnostics")

-- Private state
local initialized = false

-- Default options
local default_options = {
	-- Status options (uses status.lua's XDG-aware default)
	status_dir = M.status.get_default_dir(),
	cache_ttl = 1, -- seconds

	-- Display options
	show_idle = true,
	separator = " │ ",

	-- Polling
	status_update_interval = 500, -- ms

	-- Theme overrides (optional)
	-- theme = {
	--   status = { running = "#00ff00" },
	--   icons = { running = "🚀" },
	-- }
	theme = nil,

	-- Debug mode (verbose logging)
	debug = false,

	-- Analytics options (file-based logging for debugging)
	analytics = {
		enabled = true,
		log_status = true, -- Log status transitions (idle->running->blocked->done)
		log_dashboard = true, -- Log dashboard opens/selections
		log_errors = true, -- Log errors
		-- log_path = "~/.cache/claude-status/analytics.log", -- Default
	},

	-- Diagnostics options
	diagnostics = {
		stale_threshold = 300, -- 5 minutes - working status older than this triggers warning
	},
}

-- Active options (merged with user opts)
M.options = {}

-- Deep merge tables (tabline.wez pattern)
local function merge_options(defaults, overrides)
	local result = {}
	for k, v in pairs(defaults) do
		result[k] = v
	end
	if overrides then
		for k, v in pairs(overrides) do
			result[k] = v
		end
	end
	return result
end

-- Cleanup stale status files on startup
-- This runs every time WezTerm loads config (including wezterm connect)
local function cleanup_stale_files()
	local status_dir = default_options.status_dir
	-- Safe: only delete pane-*.json files, not the directory
	local handle = io.popen('rm -f "' .. status_dir .. '"/pane-*.json 2>/dev/null')
	if handle then
		handle:close()
	end
	wezterm.log_info("claude-agent: Cleaned stale status files from " .. status_dir)
end

-- Setup function - initialize plugin and register events (tabline.wez pattern)
-- Call this once to configure options and register event handlers
M.setup = function(opts)
	-- Clean stale files on first initialization
	-- Active Claude sessions will recreate their files via hooks
	if not initialized then
		cleanup_stale_files()
	end

	-- Merge options
	M.options = merge_options(default_options, opts)

	-- Apply theme overrides if provided
	if M.options.theme then
		M.colors.setup(M.options.theme)
	end

	-- Setup submodules with merged options
	M.status.setup({
		status_dir = M.options.status_dir,
		cache_ttl = M.options.cache_ttl,
	})

	-- Statusbar disabled - using dashboard-only approach
	-- M.statusbar.setup({ ... })

	-- Setup analytics (if enabled)
	if M.options.analytics and M.options.analytics.enabled ~= false then
		M.analytics.setup(M.options.analytics)
	end

	-- Setup diagnostics
	M.diagnostics.setup({
		debug = M.options.debug,
		stale_threshold = M.options.diagnostics and M.options.diagnostics.stale_threshold or 300,
	})

	-- Register event handlers (only once)
	if not initialized then
		-- Statusbar disabled - using dashboard-only approach
		-- M.statusbar.register_events()

		-- Register analytics event handlers (if enabled)
		if M.options.analytics and M.options.analytics.enabled ~= false then
			M.analytics.register_events()
		end

		initialized = true
	end

	wezterm.log_info("claude-agent: Plugin initialized" .. (M.options.debug and " (debug mode)" or ""))
	wezterm.emit("claude-agent.ready", M.options)
end

-- Apply config settings (tabline.wez pattern)
-- Call this to apply WezTerm config settings and keybindings
M.apply_to_config = function(config, opts)
	-- Setup if not already done
	if not initialized then
		M.setup(opts)
	elseif opts then
		-- Re-merge options if provided
		M.options = merge_options(M.options, opts)
	end

	-- Apply config settings
	config.status_update_interval = M.options.status_update_interval

	-- Register keybindings (Leader+G for dashboard, Leader+N for jump)
	M.dashboard.register_keybindings(config)

	-- Register diagnostics keybindings (Leader+Shift+G for health check)
	M.diagnostics.register_keybindings(config)
end

-- Get current configuration (tabline.wez pattern)
M.get_config = function()
	return M.options
end

-- Manual refresh trigger (tabline.wez pattern)
-- Forces status update for all windows
M.refresh = function(window)
	if window then
		-- Trigger status update event
		wezterm.emit("claude-agent.refresh", window)
	end
end

-- Export actions for custom keybindings (smart_workspace_switcher pattern)
M.actions = {
	open_dashboard = M.dashboard.open_dashboard,
	jump_to_next_waiting = M.dashboard.jump_to_next_waiting,
	open_health_check = M.diagnostics.open_health_check,
}

-- Theme API (tabline.wez pattern)
M.get_theme = function()
	return M.colors.get_theme()
end

M.set_theme = function(overrides)
	M.colors.set_theme(overrides)
end

return M
