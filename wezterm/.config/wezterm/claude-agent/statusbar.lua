-- claude-agent/statusbar.lua - Status bar cell builders
local wezterm = require("wezterm")
local colors = require("claude-agent.colors")
local status = require("claude-agent.status")
local M = {}

-- Default options
M.options = {
	show_idle = true,
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

-- Build a single status cell (icon + count)
local function status_cell(icon, count, color)
	if count <= 0 then
		return {}
	end
	return {
		{ Foreground = { Color = color } },
		{ Text = icon .. count },
	}
end

-- Build agent summary cells
M.build_agent_cells = function(counts)
	local cells = {}

	local function append(new_cells, needs_space)
		if #new_cells > 0 then
			if needs_space and #cells > 0 then
				table.insert(cells, { Text = " " })
			end
			for _, cell in ipairs(new_cells) do
				table.insert(cells, cell)
			end
		end
	end

	append(status_cell(colors.icons.running, counts.running, colors.status.running), false)
	append(status_cell(colors.icons.blocked, counts.blocked, colors.status.blocked), true)
	append(status_cell(colors.icons.waiting, counts.waiting, colors.status.waiting), true)

	if M.options.show_idle then
		append(status_cell(colors.icons.idle, counts.idle, colors.status.idle), true)
	end

	return cells
end

-- Register status bar update event
M.register_events = function()
	wezterm.on("update-right-status", function(window, _)
		-- Periodically clean up stale status files
		status.cleanup_stale_files()

		local cells = {}
		local sep = M.options.separator

		-- Section 1: Agent counts
		local counts = status.count_agents(window:mux_window())
		local agent_cells = M.build_agent_cells(counts)
		local has_agents = counts.running + counts.blocked + counts.waiting + counts.idle > 0

		if has_agents then
			for _, cell in ipairs(agent_cells) do
				table.insert(cells, cell)
			end
			table.insert(cells, { Foreground = { Color = colors.ui.muted } })
			table.insert(cells, { Text = sep })
		end

		-- Section 2: Domain
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
			table.insert(cells, { Foreground = { Color = colors.status.waiting } })
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
end

return M
