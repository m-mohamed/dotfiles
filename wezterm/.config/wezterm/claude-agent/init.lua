-- claude-agent/init.lua - Multi-agent monitoring for Claude Code
-- Pattern: Single entry point (bar.wezterm)
local wezterm = require("wezterm")
local M = {}

-- Lazy load submodules (tabline.wez pattern)
M.colors = require("claude-agent.colors")
M.status = require("claude-agent.status")
M.statusbar = require("claude-agent.statusbar")
M.dashboard = require("claude-agent.dashboard")

-- Respect XDG_CACHE_HOME if set, fallback to ~/.cache
local function get_cache_dir()
	local xdg_cache = os.getenv("XDG_CACHE_HOME")
	if xdg_cache and xdg_cache ~= "" then
		return xdg_cache .. "/claude-status"
	end
	return os.getenv("HOME") .. "/.cache/claude-status"
end

-- Default options (can be overridden via apply_to_config)
M.options = {
	-- Status options
	status_dir = get_cache_dir(),
	cache_ttl = 1, -- seconds

	-- Display options
	show_idle = true,
	separator = " │ ",

	-- Polling
	status_update_interval = 500, -- ms
}

-- Single entry point (bar.wezterm pattern)
M.apply_to_config = function(config, opts)
	-- Merge user options with defaults
	if opts then
		for k, v in pairs(opts) do
			M.options[k] = v
		end
	end

	-- Setup submodules with merged options
	M.status.setup({
		status_dir = M.options.status_dir,
		cache_ttl = M.options.cache_ttl,
	})

	M.statusbar.setup({
		show_idle = M.options.show_idle,
		separator = M.options.separator,
	})

	-- Dashboard uses auto-detected defaults, no setup needed

	-- Register event handlers
	M.statusbar.register_events()

	-- Register keybindings (Leader+G for dashboard, Leader+N for jump)
	M.dashboard.register_keybindings(config)

	-- Apply config settings
	config.status_update_interval = M.options.status_update_interval

	wezterm.log_info("claude-agent: Plugin initialized")

	-- Emit ready event for extensibility
	wezterm.emit("claude-agent.ready", M.options)
end

-- Export actions for custom keybinding
M.actions = {
	open_dashboard = M.dashboard.open_dashboard,
	jump_to_next_waiting = M.dashboard.jump_to_next_waiting,
}

return M
