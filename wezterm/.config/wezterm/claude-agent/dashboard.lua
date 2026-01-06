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
-- 4-state system: attention → compacting → working → idle
local status_priority = {
	attention = 1,
	compacting = 2,
	working = 3,
	idle = 4,
	unknown = 5,
}

-- get_cli_panes is now in status.lua (status.get_cli_panes)

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
-- PRIMARY: Scans filesystem for status files (reliable, like Health Check)
-- SECONDARY: Uses CLI for metadata (title, workspace) when available
M.get_agents = function()
	local agents = {}

	-- Clear status cache to ensure fresh reads
	status.clear_cache()

	-- PRIMARY: Scan filesystem for all status files (like Health Check does)
	-- This is more reliable than CLI enumeration in callback contexts
	local status_dir = status.options.status_dir
	local ok, entries = pcall(wezterm.read_dir, status_dir)

	if not ok or not entries then
		wezterm.log_warn("claude-agent: Failed to read status directory")
		return agents
	end

	-- Build lookup of CLI panes for metadata (title, workspace)
	-- CLI may return partial data, so we use it only for enhancement
	local cli_lookup = {}
	local cli_panes = status.get_cli_panes()
	if cli_panes then
		for _, p in ipairs(cli_panes) do
			cli_lookup[tostring(p.pane_id)] = p
		end
	end

	-- Process each status file found in directory
	for _, filepath in ipairs(entries) do
		local filename = filepath:match("([^/]+)$")
		if filename then
			local pane_id_str = filename:match("pane%-(%d+)%.json")
			if pane_id_str then
				local pane_id = tonumber(pane_id_str)
				local status_data = status.read_file(pane_id)

				if status_data then
					-- Get CLI metadata if available
					local cli_pane = cli_lookup[pane_id_str]

					-- For DISPLAY: prefer CLI workspace, fallback to project is OK
					local display_workspace = (cli_pane and cli_pane.workspace) or status_data.project or "unknown"

					-- For NAVIGATION: ONLY use CLI workspace (nil if unavailable)
					-- Project name != workspace name, so don't use project as fallback
					local nav_workspace = cli_pane and cli_pane.workspace -- nil if no CLI data

					-- Project/repo name comes from status file (git repo name from hooks)
					local project = status_data.project or "unknown"
					local tab_id = (cli_pane and cli_pane.tab_id) or 0

					local agent_status = status_data.status or "unknown"

					table.insert(agents, {
						tab_id = tab_id,
						pane_id = pane_id,
						workspace = display_workspace, -- For display in label
						nav_workspace = nav_workspace, -- For SwitchToWorkspace (can be nil)
						project = project,
						status = agent_status,
						start_time = status_data.start_time,
						priority = status_priority[agent_status] or 5,
					})
				end
			end
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
-- 4-state system: attention (🔔), compacting (🔄), working (🤖), idle (⏸️)
M.get_choices = function()
	local agents = M.get_agents()
	local choices = {}
	local counts = { attention = 0, compacting = 0, working = 0, idle = 0 }
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
			local icon = colors.icons[agent.status] or "?"
			if agent.status == "attention" then
				sep_label = string.format("─── %s NEEDS ATTENTION ─────────────", icon)
			elseif agent.status == "compacting" then
				sep_label = string.format("─── %s COMPACTING ──────────────────", icon)
			elseif agent.status == "working" then
				sep_label = string.format("─── %s WORKING ─────────────────────", icon)
			elseif agent.status == "idle" then
				sep_label = string.format("─── %s IDLE ────────────────────────", icon)
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

		-- Build formatted label: [workspace] project (elapsed)
		local label_parts = {
			{ Foreground = { Color = color } },
			{ Text = icon .. " " },
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = "[" .. agent.workspace .. "] " },
			{ Foreground = { Color = colors.ui.fg } },
			{ Text = agent.project },
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = elapsed_str },
		}

		-- Add background highlight for attention-needed agents
		if agent.status == "attention" then
			table.insert(label_parts, 1, { Background = { Color = "#2a2a3d" } })
		end

		-- Encode nav_workspace in ID for selection handler (empty string if nil)
		local nav_ws = agent.nav_workspace or ""
		table.insert(choices, {
			id = string.format("%d:%d:%s:%s", agent.tab_id, agent.pane_id, nav_ws, agent.workspace),
			label = wezterm.format(label_parts),
		})
	end

	return choices, counts
end

-- Validate agents and log any issues (called on dashboard open)
local function validate_agents(agents)
	local now = os.time()
	local stale_threshold = 300 -- 5 minutes

	for _, agent in ipairs(agents) do
		-- Check for stale "working" status
		if agent.status == "working" and agent.start_time then
			local age = now - agent.start_time
			if age > stale_threshold then
				wezterm.log_warn(string.format(
					"claude-agent: Stale 'working' status on pane %d (%dm old) - hooks may not be firing",
					agent.pane_id, math.floor(age / 60)
				))
			end
		end
	end
end

-- Agent Dashboard action
M.open_dashboard = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local choices, counts = M.get_choices()

		local total = counts.attention + counts.compacting + counts.working + counts.idle
		wezterm.log_info("claude-agent: Dashboard opened, found " .. total .. " agents")

		-- Run validation on agents
		local agents = M.get_agents()
		validate_agents(agents)

		-- Emit event
		wezterm.emit("claude-agent.dashboard.opened", window, total, counts)

		if #choices == 0 then
			window:toast_notification("Agent Dashboard", "No Claude agents found", nil, 3000)
			return
		end

		-- Build summary for title (4-state system)
		local summary_parts = {}
		if counts.attention > 0 then
			table.insert(summary_parts, counts.attention .. " attention")
		end
		if counts.compacting > 0 then
			table.insert(summary_parts, counts.compacting .. " compacting")
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

					-- Extract: tab_id:pane_id:nav_workspace:display_workspace
					-- nav_workspace can be empty string if CLI data unavailable
					local tab_id, pane_id, nav_workspace, display_workspace = id:match("(%d+):(%d+):([^:]*):(.+)")
					pane_id = tonumber(pane_id)

					-- Emit event
					wezterm.emit("claude-agent.dashboard.selected", inner_window, pane_id)

					-- Activate pane directly via CLI
					-- This works globally across all workspaces - no need for SwitchToWorkspace
					-- (perform_action was async and caused race conditions)
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

-- Jump to next agent that needs attention (4-state system)
M.jump_to_next_waiting = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local agents = M.get_agents()

		for _, agent in ipairs(agents) do
			if agent.status == "attention" then
				wezterm.log_info("claude-agent: Jumping to attention agent")

				-- Activate pane directly via CLI
				-- This works globally across all workspaces - no need for SwitchToWorkspace
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
