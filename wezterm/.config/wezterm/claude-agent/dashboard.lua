-- claude-agent/dashboard.lua - Agent dashboard with InputSelector
local wezterm = require("wezterm")
local act = wezterm.action
local colors = require("claude-agent.colors")
local status = require("claude-agent.status")
local M = {}

-- Detect wezterm CLI path
local function find_wezterm_cli()
	-- Check common locations
	local paths = {
		"/opt/homebrew/bin/wezterm", -- macOS Homebrew ARM
		"/usr/local/bin/wezterm", -- macOS Homebrew Intel / Linux
		"/usr/bin/wezterm", -- Linux system
	}
	for _, path in ipairs(paths) do
		local f = io.open(path, "r")
		if f then
			f:close()
			return path
		end
	end
	return "wezterm" -- Fallback to PATH lookup
end

-- Default options
M.options = {
	show_idle = true,
	wezterm_cli_path = find_wezterm_cli(),
}

-- Priority order for agent status (attention-needed first)
local status_priority = {
	blocked = 1,
	waiting = 2,
	running = 3,
	idle = 4,
	unknown = 5,
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

-- Collect all Claude agents with metadata
M.get_agents = function()
	local agents = {}

	local all_windows = wezterm.mux.all_windows()
	if not all_windows then
		return agents
	end

	for _, mux_win in ipairs(all_windows) do
		local workspace = mux_win:get_workspace() or "default"
		local tabs = mux_win:tabs()
		if not tabs then
			goto continue_window
		end

		for _, tab in ipairs(tabs) do
			local panes = tab:panes()
			if not panes then
				goto continue_tab
			end

			for _, pane in ipairs(panes) do
				local title = pane:get_title() or ""
				local pane_id = pane:pane_id()

				local status_data = status.read_cached(pane_id)

				-- Check if this is a Claude Code pane
				local has_status_file = status_data ~= nil
				local has_claude_title = title:match("^✳") or title:lower():match("claude")

				if has_status_file or has_claude_title then
					local agent_status = status_data and status_data.status or "unknown"
					local start_time = status_data and status_data.start_time
					local project = status_data and status_data.project or workspace

					-- Clean title (remove ✳ prefix)
					local clean_title = title:gsub("^✳%s*", "")

					table.insert(agents, {
						tab_id = tab:tab_id(),
						pane_id = pane_id,
						workspace = workspace,
						project = project,
						title = clean_title,
						status = agent_status,
						start_time = start_time,
						priority = status_priority[agent_status] or 5,
					})
				end
			end
			::continue_tab::
		end
		::continue_window::
	end

	-- Sort by priority (blocked → waiting → running → idle)
	table.sort(agents, function(a, b)
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		return (a.workspace or "") < (b.workspace or "")
	end)

	return agents
end

-- Build dashboard choices with separators and colors
M.get_choices = function()
	local agents = M.get_agents()
	local choices = {}
	local counts = { blocked = 0, waiting = 0, running = 0, idle = 0 }
	local last_status = nil

	-- Count agents by status
	for _, agent in ipairs(agents) do
		if counts[agent.status] then
			counts[agent.status] = counts[agent.status] + 1
		end
	end

	-- Build choices with separators
	for _, agent in ipairs(agents) do
		-- Add separator when status changes
		if agent.status ~= last_status then
			local sep_label = ""
			if agent.status == "blocked" then
				sep_label = "─── 🔐 NEEDS PERMISSION ─────────────"
			elseif agent.status == "waiting" then
				sep_label = "─── 🔔 NEEDS INPUT ──────────────────"
			elseif agent.status == "running" then
				sep_label = "─── 🤖 RUNNING ──────────────────────"
			elseif agent.status == "idle" then
				sep_label = "─── ⏸️ IDLE ──────────────────────────"
			end

			if sep_label ~= "" then
				table.insert(choices, {
					id = "sep_" .. agent.status,
					label = wezterm.format({
						{ Foreground = { Color = colors.ui.muted } },
						{ Text = sep_label },
					}),
				})
			end
			last_status = agent.status
		end

		-- Format elapsed time
		local elapsed_str = ""
		if agent.start_time then
			local elapsed = status.format_elapsed(agent.start_time)
			if elapsed then
				elapsed_str = " (" .. elapsed .. ")"
			end
		end

		-- Get status icon and color
		local icon = colors.icons[agent.status] or colors.icons.unknown
		local color = colors.status[agent.status] or colors.status.unknown

		-- Build formatted label
		local label_parts = {
			{ Foreground = { Color = color } },
			{ Text = icon .. " " },
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = "[" .. agent.workspace .. "] " },
			{ Foreground = { Color = colors.ui.fg } },
			{ Text = agent.title },
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = elapsed_str },
		}

		-- Add background highlight for attention-needed agents
		if agent.status == "blocked" or agent.status == "waiting" then
			table.insert(label_parts, 1, { Background = { Color = "#2a2a3d" } })
		end

		table.insert(choices, {
			id = string.format("%d:%d:%s", agent.tab_id, agent.pane_id, agent.workspace),
			label = wezterm.format(label_parts),
		})
	end

	return choices, counts
end

-- Agent Dashboard action
M.open_dashboard = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local choices, counts = M.get_choices()

		local total = counts.blocked + counts.waiting + counts.running + counts.idle
		wezterm.log_info("claude-agent: Dashboard opened, found " .. total .. " agents")

		-- Emit event
		wezterm.emit("claude-agent.dashboard.opened", window, total, counts)

		if #choices == 0 then
			window:toast_notification("Agent Dashboard", "No Claude agents found", nil, 3000)
			return
		end

		-- Build summary for title
		local summary_parts = {}
		if counts.blocked > 0 then
			table.insert(summary_parts, counts.blocked .. " blocked")
		end
		if counts.waiting > 0 then
			table.insert(summary_parts, counts.waiting .. " waiting")
		end
		if counts.running > 0 then
			table.insert(summary_parts, counts.running .. " running")
		end
		if counts.idle > 0 then
			table.insert(summary_parts, counts.idle .. " idle")
		end
		local summary = table.concat(summary_parts, ", ")

		window:perform_action(
			act.InputSelector({
				title = "Agent Dashboard (" .. summary .. ")",
				description = "Select an agent to jump to (/ to search)",
				choices = choices,
				fuzzy = true,
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id or id:match("^sep_") then
						return
					end

					local tab_id, pane_id, workspace = id:match("(%d+):(%d+):(.+)")
					pane_id = tonumber(pane_id)

					-- Emit event
					wezterm.emit("claude-agent.dashboard.selected", inner_window, pane_id)

					-- Switch to workspace
					if workspace then
						inner_window:perform_action(act.SwitchToWorkspace({ name = workspace }), inner_pane)
					end

					-- Activate pane
					if pane_id then
						wezterm.run_child_process({
							M.options.wezterm_cli_path,
							"cli",
							"activate-pane",
							"--pane-id",
							tostring(pane_id),
						})
					end
				end),
			}),
			pane
		)
	end)

	if not ok then
		window:toast_notification("Dashboard Error", tostring(err), nil, 5000)
		wezterm.log_error("claude-agent: Dashboard error: " .. tostring(err))
		wezterm.emit("claude-agent.error", "dashboard", tostring(err))
	end
end)

-- Jump to next agent that needs attention
M.jump_to_next_waiting = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local agents = M.get_agents()

		for _, agent in ipairs(agents) do
			if agent.status == "blocked" or agent.status == "waiting" then
				wezterm.log_info("claude-agent: Jumping to " .. agent.status .. " agent")

				if agent.workspace then
					window:perform_action(act.SwitchToWorkspace({ name = agent.workspace }), pane)
				end

				if agent.pane_id then
					wezterm.run_child_process({
						M.options.wezterm_cli_path,
						"cli",
						"activate-pane",
						"--pane-id",
						tostring(agent.pane_id),
					})
				end

				window:toast_notification(
					"Agent Found",
					string.format("%s in %s", colors.icons[agent.status] or "?", agent.workspace or "?"),
					nil,
					2000
				)
				return
			end
		end

		window:toast_notification("No Agents Waiting", "All agents are running or idle", nil, 2000)
	end)

	if not ok then
		wezterm.log_error("claude-agent: Jump error: " .. tostring(err))
	end
end)

-- Register keybindings
M.register_keybindings = function(config)
	-- Ensure keys table exists
	config.keys = config.keys or {}

	-- Add dashboard keybinding (Leader + G)
	table.insert(config.keys, {
		key = "g",
		mods = "LEADER",
		action = M.open_dashboard,
	})

	-- Add jump to next waiting (Leader + N)
	table.insert(config.keys, {
		key = "n",
		mods = "LEADER",
		action = M.jump_to_next_waiting,
	})
end

return M
