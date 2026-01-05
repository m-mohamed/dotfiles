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
	wezterm_cli_path = find_wezterm_cli(),
}

-- Priority order for agent status (attention-needed first)
-- 3-state system: attention → working → idle
local status_priority = {
	attention = 1,
	working = 2,
	idle = 3,
	unknown = 4,
}

-- Get panes from wezterm CLI (returns correct pane_ids that match $WEZTERM_PANE)
-- This is needed because mux.all_windows():pane_id() returns internal mux IDs
-- which differ from the shell's $WEZTERM_PANE environment variable
-- NOTE: Uses run_child_process (not io.popen) to avoid blocking GUI thread
local function get_cli_panes()
	local cli_path = M.options.wezterm_cli_path
	local success, stdout, stderr = wezterm.run_child_process({ cli_path, "cli", "list", "--format", "json" })
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
-- Uses wezterm CLI for pane enumeration to get correct pane_ids that match $WEZTERM_PANE
M.get_agents = function()
	local agents = {}

	-- Clear status cache to ensure fresh reads (pane IDs are unstable with Unix domains)
	status.clear_cache()

	-- Get panes from CLI (correct pane_ids)
	local cli_panes = get_cli_panes()
	if not cli_panes then
		wezterm.log_warn("claude-agent: CLI pane enumeration failed")
		cli_panes = {}
	end

	for _, cli_pane in ipairs(cli_panes) do
		local pane_id = cli_pane.pane_id
		local workspace = cli_pane.workspace or "default"
		local title = cli_pane.title or ""
		local tab_id = cli_pane.tab_id or 0

		-- Read status file using CLI's pane_id (matches $WEZTERM_PANE)
		local status_data = status.read_cached(pane_id)

		-- Check if this is a Claude Code pane
		local has_status_file = status_data ~= nil
		local has_claude_title = title:match("^✳")
			or title:lower():match("claude")
			or title:match("^%d+%.%d+%.%d+$") -- version like "2.0.75"

		if has_status_file or has_claude_title then
			local agent_status = (status_data and status_data.status) or "unknown"
			local start_time = status_data and status_data.start_time
			local project = status_data and status_data.project or workspace

			-- Clean title (remove ✳ prefix)
			local clean_title = title:gsub("^✳%s*", "")

			table.insert(agents, {
				tab_id = tab_id,
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

	-- Sort by priority (attention → working → idle → unknown)
	table.sort(agents, function(a, b)
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		return (a.workspace or "") < (b.workspace or "")
	end)

	return agents
end

-- Build dashboard choices with separators and colors
-- 3-state system: attention (🔔), working (🤖), idle (⏸️)
M.get_choices = function()
	local agents = M.get_agents()
	local choices = {}
	local counts = { attention = 0, working = 0, idle = 0 }
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
			if agent.status == "attention" then
				sep_label = "─── 🔔 NEEDS ATTENTION ─────────────"
			elseif agent.status == "working" then
				sep_label = "─── 🤖 WORKING ─────────────────────"
			elseif agent.status == "idle" then
				sep_label = "─── ⏸️  IDLE ───────────────────────"
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
		if agent.status == "attention" then
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

		local total = counts.attention + counts.working + counts.idle
		wezterm.log_info("claude-agent: Dashboard opened, found " .. total .. " agents")

		-- Emit event
		wezterm.emit("claude-agent.dashboard.opened", window, total, counts)

		if #choices == 0 then
			window:toast_notification("Agent Dashboard", "No Claude agents found", nil, 3000)
			return
		end

		-- Build summary for title (3-state system)
		local summary_parts = {}
		if counts.attention > 0 then
			table.insert(summary_parts, counts.attention .. " attention")
		end
		if counts.working > 0 then
			table.insert(summary_parts, counts.working .. " working")
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
					-- Handle cancellation (smart_workspace_switcher pattern)
					if not id then
						wezterm.emit("claude-agent.dashboard.canceled", inner_window)
						return
					end

					-- Ignore separator selections
					if id:match("^sep_") then
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

					-- Activate pane (use background process to avoid GUI freeze)
					if pane_id then
						wezterm.background_child_process({
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

-- Jump to next agent that needs attention (3-state system)
M.jump_to_next_waiting = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local agents = M.get_agents()

		for _, agent in ipairs(agents) do
			if agent.status == "attention" then
				wezterm.log_info("claude-agent: Jumping to attention agent")

				if agent.workspace then
					window:perform_action(act.SwitchToWorkspace({ name = agent.workspace }), pane)
				end

				if agent.pane_id then
					wezterm.background_child_process({
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
