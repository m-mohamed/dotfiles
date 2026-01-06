-- claude-agent/diagnostics.lua - Health checks and validation for debugging
local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

-- Lazy-load dependencies to avoid circular requires
local function get_status()
	return require("claude-agent.status")
end

local function get_colors()
	return require("claude-agent.colors")
end

local function get_analytics()
	return require("claude-agent.analytics")
end

-- Default options
M.options = {
	debug = false,
	stale_threshold = 300, -- 5 minutes - working status older than this is suspicious
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

-- Debug logging helper
M.debug_log = function(msg)
	if M.options.debug then
		wezterm.log_info("claude-agent: [DEBUG] " .. msg)
	end
end

-- Get all status files from the cache directory
M.get_all_status_files = function()
	local status = get_status()
	local status_dir = status.options.status_dir
	local files = {}

	local ok, entries = pcall(wezterm.read_dir, status_dir)
	if not ok or not entries then
		return files
	end

	for _, filepath in ipairs(entries) do
		local filename = filepath:match("([^/]+)$")
		if filename then
			local pane_id = filename:match("pane%-(%d+)%.json")
			if pane_id then
				local data = status.read_file(pane_id)
				if data then
					table.insert(files, {
						pane_id = tonumber(pane_id),
						filename = filename,
						status = data.status,
						project = data.project,
						start_time = data.start_time,
						attention_type = data.attention_type,
					})
				end
			end
		end
	end

	return files
end

-- Get user vars from all panes in current window
M.get_user_vars = function(mux_window)
	local status = get_status()
	local vars = {}

	if not mux_window then
		return vars
	end

	local tabs = mux_window:tabs()
	if not tabs then
		return vars
	end

	for _, tab in ipairs(tabs) do
		local panes = tab:panes()
		if panes then
			for _, pane in ipairs(panes) do
				local pane_id = pane:pane_id()
				local user_var = status.read_user_var(pane)
				if user_var then
					table.insert(vars, {
						pane_id = pane_id,
						status = user_var,
					})
				end
			end
		end
	end

	return vars
end

-- Get CLI panes for comparison
M.get_cli_panes = function()
	local status = get_status()
	return status.get_current_pane_ids()
end

-- Run comprehensive health check
M.run_health_check = function(mux_window)
	local status = get_status()
	local analytics = get_analytics()
	local now = os.time()

	local results = {
		status_files = M.get_all_status_files(),
		user_vars = M.get_user_vars(mux_window),
		cli_panes = M.get_cli_panes(),
		mismatches = {},
		stale_statuses = {},
		orphan_files = {},
		issues = {},
	}

	-- Build lookup tables
	local file_by_pane = {}
	for _, f in ipairs(results.status_files) do
		file_by_pane[tostring(f.pane_id)] = f
	end

	local var_by_pane = {}
	for _, v in ipairs(results.user_vars) do
		var_by_pane[tostring(v.pane_id)] = v
	end

	-- Check for mismatches (file status != user var status)
	for pane_id_str, file_data in pairs(file_by_pane) do
		local var_data = var_by_pane[pane_id_str]
		if var_data and file_data.status ~= var_data.status then
			local mismatch = {
				pane_id = file_data.pane_id,
				file_status = file_data.status,
				user_var_status = var_data.status,
			}
			table.insert(results.mismatches, mismatch)
			table.insert(results.issues, string.format(
				"MISMATCH: pane %d has file=%s but user_var=%s",
				file_data.pane_id, file_data.status, var_data.status
			))

			-- Log to analytics
			analytics.log_mismatch(file_data.pane_id, file_data.status, var_data.status)
		end
	end

	-- Check for stale working statuses
	for _, file_data in ipairs(results.status_files) do
		if file_data.status == "working" and file_data.start_time then
			local age = now - file_data.start_time
			if age > M.options.stale_threshold then
				table.insert(results.stale_statuses, {
					pane_id = file_data.pane_id,
					status = file_data.status,
					age = age,
				})
				table.insert(results.issues, string.format(
					"STALE: pane %d 'working' for %dm (hooks may not be firing)",
					file_data.pane_id, math.floor(age / 60)
				))

				-- Log to analytics
				analytics.log_stale_status(file_data.pane_id, file_data.status, age)
			end
		end
	end

	-- Check for orphan files (files for panes that don't exist)
	-- SAFETY: Only flag orphans if CLI returned meaningful data
	-- wezterm.run_child_process is unreliable in InputSelector callback contexts
	local cli_pane_count = 0
	for _ in pairs(results.cli_panes) do
		cli_pane_count = cli_pane_count + 1
	end
	local status_file_count = #results.status_files

	if cli_pane_count == 0 then
		-- CLI returned empty - skip orphan detection entirely
		table.insert(results.issues, "CLI enumeration unavailable - orphan detection skipped")
	elseif cli_pane_count < status_file_count then
		-- CLI returned fewer panes than status files - likely CLI failure
		table.insert(results.issues, string.format(
			"CLI returned %d panes but %d status files exist - possible CLI failure",
			cli_pane_count, status_file_count
		))
	else
		-- CLI returned meaningful data - safe to check for orphans
		for pane_id_str, file_data in pairs(file_by_pane) do
			if not results.cli_panes[pane_id_str] then
				table.insert(results.orphan_files, {
					pane_id = file_data.pane_id,
					filename = file_data.filename,
				})
				table.insert(results.issues, string.format(
					"ORPHAN: pane-%d.json exists but pane not found",
					file_data.pane_id
				))

				-- Log to analytics
				analytics.log_orphan_file(file_data.pane_id, "pane_not_found")
			end
		end
	end

	return results
end

-- Format health check results for display
M.format_health_check = function(results)
	local colors = get_colors()
	local lines = {}

	-- Status Files section
	table.insert(lines, {
		{ Foreground = { Color = colors.ui.muted } },
		{ Text = "--- Status Files ---" },
	})

	if #results.status_files == 0 then
		table.insert(lines, {
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = "  (none)" },
		})
	else
		for _, f in ipairs(results.status_files) do
			local icon = colors.icons[f.status] or "?"
			local status_color = colors.status[f.status] or colors.status.unknown
			local project_short = (f.project or "?"):sub(1, 20)
			table.insert(lines, {
				{ Foreground = { Color = status_color } },
				{ Text = string.format("  %s pane-%d: %s (%s)", icon, f.pane_id, f.status, project_short) },
			})
		end
	end

	-- User Vars section
	table.insert(lines, {
		{ Foreground = { Color = colors.ui.muted } },
		{ Text = "--- User Vars (current window) ---" },
	})

	if #results.user_vars == 0 then
		table.insert(lines, {
			{ Foreground = { Color = colors.ui.muted } },
			{ Text = "  (none)" },
		})
	else
		for _, v in ipairs(results.user_vars) do
			local icon = colors.icons[v.status] or "?"
			local status_color = colors.status[v.status] or colors.status.unknown
			table.insert(lines, {
				{ Foreground = { Color = status_color } },
				{ Text = string.format("  %s pane %d: %s", icon, v.pane_id, v.status) },
			})
		end
	end

	-- Summary section
	table.insert(lines, {
		{ Foreground = { Color = colors.ui.muted } },
		{ Text = "--- Summary ---" },
	})

	local cli_count = 0
	for _ in pairs(results.cli_panes) do
		cli_count = cli_count + 1
	end

	table.insert(lines, {
		{ Foreground = { Color = colors.ui.fg } },
		{ Text = string.format("  CLI panes: %d, Status files: %d", cli_count, #results.status_files) },
	})

	-- Issues section
	if #results.issues > 0 then
		table.insert(lines, {
			{ Foreground = { Color = colors.status.attention } },
			{ Text = "--- Issues Detected ---" },
		})
		for _, issue in ipairs(results.issues) do
			table.insert(lines, {
				{ Foreground = { Color = colors.status.attention } },
				{ Text = "  " .. issue },
			})
		end
	else
		table.insert(lines, {
			{ Foreground = { Color = "#50fa7b" } },
			{ Text = "  No issues detected" },
		})
	end

	return lines
end

-- Build choices for InputSelector display
M.build_health_choices = function(results)
	local formatted = M.format_health_check(results)
	local choices = {}

	for i, line_parts in ipairs(formatted) do
		table.insert(choices, {
			id = "line_" .. i,
			label = wezterm.format(line_parts),
		})
	end

	return choices
end

-- Open health check overlay
M.open_health_check = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local mux_window = window:mux_window()
		local results = M.run_health_check(mux_window)
		local choices = M.build_health_choices(results)

		M.debug_log("Health check: " .. #results.status_files .. " files, " .. #results.issues .. " issues")

		-- Emit event
		wezterm.emit("claude-agent.health_check", window, results)

		local title = string.format("Health Check (%d issues)", #results.issues)
		if #results.issues == 0 then
			title = "Health Check (all good)"
		end

		window:perform_action(
			act.InputSelector({
				title = title,
				description = "Press Escape to close",
				choices = choices,
				fuzzy = false,
				action = wezterm.action_callback(function() end), -- No-op on selection
			}),
			pane
		)
	end)

	if not ok then
		wezterm.log_error("claude-agent: Health check error: " .. tostring(err))
		window:toast_notification("Health Check Error", tostring(err), nil, 5000)
	end
end)

-- Register keybindings
M.register_keybindings = function(config)
	config.keys = config.keys or {}

	-- Health check (Leader + Shift + G)
	table.insert(config.keys, {
		key = "G",
		mods = "LEADER|SHIFT",
		action = M.open_health_check,
	})
end

return M
