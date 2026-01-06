-- claude-agent/statusbar.lua - Status bar (domain, workspace, leader, process)
--
-- STATUS: DISABLED - This module is NOT registered in init.lua
-- Kept for reference in case status bar agent counts are wanted later.
-- The dashboard (Ctrl+A G) is now the primary way to view agent status.
--
-- To enable: uncomment M.statusbar.register_events() in init.lua:141
--
-- NOTE: Agent counts removed - use dashboard (Ctrl+A G) for agent status
local wezterm = require("wezterm")
local colors = require("claude-agent.colors")
local status = require("claude-agent.status")
local M = {}

-- Default options
M.options = {
	separator = " │ ",
}

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

-- Register status bar update event
M.register_events = function()
	wezterm.on("update-right-status", function(window, _)
		-- Wrap in pcall to prevent errors from breaking status bar updates
		local ok, err = pcall(function()
			-- Periodically clean up stale status files
			status.cleanup_stale_files()

			local cells = {}
			local sep = M.options.separator

			-- Section 1: Domain
			local active_pane = window:active_pane()
			if not active_pane then
				return
			end
			local domain_name = active_pane:get_domain_name() or "local"
			table.insert(cells, { Foreground = { Color = colors.ui.muted } })
			table.insert(cells, { Text = "[" .. domain_name .. "]" .. sep })

			-- Section 3: Workspace
			local workspace = window:active_workspace() or ""
			if workspace ~= "" then
				table.insert(cells, { Foreground = { Color = colors.ui.fg } })
				table.insert(cells, { Text = "[" .. workspace .. "]" .. sep })
			end

			-- Section 4: Leader indicator
			if window:leader_is_active() then
				table.insert(cells, { Foreground = { Color = colors.status.attention } })
				table.insert(cells, { Text = "LEADER" .. sep })
			end

			-- Section 5: Process name
			local process_name = active_pane:get_foreground_process_name() or ""
			process_name = process_name:gsub(".*/", ""):gsub("%.exe$", "")
			if process_name ~= "" then
				table.insert(cells, { Foreground = { Color = colors.ui.fg } })
				table.insert(cells, { Text = process_name })
			end

			window:set_right_status(wezterm.format(cells))
		end)

		if not ok then
			wezterm.log_error("claude-agent: Statusbar error: " .. tostring(err))
			-- Emit error event for extensibility (smart_workspace_switcher pattern)
			wezterm.emit("claude-agent.error", "statusbar", tostring(err))
		end
	end)
end

return M
