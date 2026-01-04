local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Basic Settings                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.disable_default_key_bindings = true
config.font_size = 22
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.window_decorations = "RESIZE"
config.use_dead_keys = false
-- macOS Option/Alt key behavior: send Alt/Meta instead of composed characters
-- Left Alt = Meta/Alt modifier (for Aerospace window manager and CLI tools)
-- Right Alt = Meta/Alt modifier (consistent behavior)
-- This allows Alt+key combinations to work properly in terminal applications
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.pane_focus_follows_mouse = true
config.scrollback_lines = 10000
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Leader Key (Ctrl+a) - Screen/Tmux Standard                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Tab Bar Settings                                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Session Management with Persistent Unix Domain                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.unix_domains = {
	{
		name = "unix",
		-- Predictive local echo for latency >10ms (improves perceived responsiveness)
		local_echo_threshold_ms = 10,
	},
}

config.window_close_confirmation = "AlwaysPrompt"
config.default_workspace = "default"
config.default_gui_startup_args = { "connect", "unix" }

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Color Scheme                                                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local tokyo_night = {
	foreground = "#c0caf5",
	background = "#1a1b26",
	cursor_bg = "#c0caf5",
	cursor_border = "#c0caf5",
	cursor_fg = "#1a1b26",
	selection_bg = "#283457",
	selection_fg = "#c0caf5",
	split = "#7aa2f7",
	compose_cursor = "#ff9e64",
	scrollbar_thumb = "#292e42",
	ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
	brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
	tab_bar = {
		inactive_tab_edge = "#16161e",
		background = "#1a1b26",
		active_tab = {
			fg_color = "#16161e",
			bg_color = "#7aa2f7",
		},
		inactive_tab = {
			fg_color = "#545c7e",
			bg_color = "#292e42",
		},
		inactive_tab_hover = {
			fg_color = "#7aa2f7",
			bg_color = "#292e42",
		},
		new_tab_hover = {
			fg_color = "#7aa2f7",
			bg_color = "#1a1b26",
			intensity = "Bold",
		},
		new_tab = {
			fg_color = "#7aa2f7",
			bg_color = "#1a1b26",
		},
	},
}

config.color_schemes = {
	["TokyoNight"] = tokyo_night,
}
config.color_scheme = "TokyoNight"

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Modern Terminal Features                                             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Hyperlink detection and patterns
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom hyperlink patterns
table.insert(config.hyperlink_rules, {
	regex = [[\b[A-Za-z0-9-_]+/[A-Za-z0-9-_]+#\d+\b]],
	format = "https://github.com/$0",
})

-- Mouse bindings
config.mouse_bindings = {
	-- Right-click paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
	-- Ctrl+scroll to zoom
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "CTRL",
		action = act.IncreaseFontSize,
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "CTRL",
		action = act.DecreaseFontSize,
	},
}

-- Disable audible bell, use visual bell
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Notification Handling for Multi-Agent Workflow                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Always show OSC 777 notifications (even when window is focused)
config.notification_handling = "AlwaysShow"

-- Bell event handler - convert terminal bells to toast notifications for Claude
wezterm.on("bell", function(window, pane)
	local process = pane:get_foreground_process_name() or ""
	if process:match("claude") then
		window:toast_notification("Claude Code", "Agent ready for input", nil, 4000)
	end
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Multi-Agent Tab Title Formatting (Antigravity-inspired)              ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Tokyo Night color palette for agent status
local agent_colors = {
	idle = "#565f89", -- Gray
	running = "#7aa2f7", -- Blue
	blocked = "#ff9e64", -- Orange
	waiting = "#e0af68", -- Yellow
	unknown = "#565f89", -- Gray
	fg = "#c0caf5", -- Default text
	muted = "#565f89", -- Muted text
}

-- Status icons (Antigravity-style)
local status_icons = {
	idle = "⏸️",
	running = "🤖",
	blocked = "🔐",
	waiting = "🔔",
	unknown = "⚪",
}

-- Helper to format elapsed time
local function format_elapsed(start_time)
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

-- Read Claude status from file (file-based communication since hooks are detached)
-- Pattern: JSON validation before parse (from resurrect.wezterm)
local function read_claude_status(pane_id)
	local path = wezterm.home_dir .. "/.cache/claude-status/pane-" .. tostring(pane_id) .. ".json"
	local f = io.open(path, "r")
	if not f then
		return nil
	end

	local content = f:read("*a")
	f:close()

	-- Validate not empty (pattern from resurrect.wezterm)
	if not content or content == "" then
		wezterm.log_warn("claude-agent: Empty status file for pane " .. tostring(pane_id))
		return nil
	end

	-- Parse with pcall
	local ok, data = pcall(wezterm.json_parse, content)
	if not ok then
		wezterm.log_warn("claude-agent: Invalid JSON in pane-" .. tostring(pane_id) .. ".json")
		return nil
	end

	-- Validate expected schema
	if type(data) ~= "table" or not data.status then
		wezterm.log_warn("claude-agent: Missing 'status' field for pane " .. tostring(pane_id))
		return nil
	end

	return data
end

-- Track last cleanup time to avoid running too frequently
local last_cleanup_time = 0

-- Get all current pane IDs
local function get_current_pane_ids()
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
local function cleanup_stale_status_files()
	local now = os.time()
	-- Only run cleanup every 5 minutes
	if now - last_cleanup_time < 300 then
		return
	end
	last_cleanup_time = now

	-- Get current pane IDs for orphan detection
	local current_panes = get_current_pane_ids()
	local status_dir = wezterm.home_dir .. "/.cache/claude-status"

	-- Read directory and remove orphaned files
	local handle = io.popen('ls "' .. status_dir .. '" 2>/dev/null')
	if handle then
		for file in handle:lines() do
			local pane_id = file:match("pane%-(%d+)%.json")
			if pane_id and not current_panes[pane_id] then
				-- Remove orphaned file
				os.remove(status_dir .. "/" .. file)
			end
		end
		handle:close()
	end

	-- Also clean files older than 1 hour (backup cleanup)
	wezterm.background_child_process({
		"zsh",
		"-c",
		[[find ~/.cache/claude-status -name "pane-*.json" -type f -mmin +60 -delete 2>/dev/null]],
	})
end

-- Show agent state icons in tab titles with colors and elapsed time
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local pane = tab.active_pane

	-- Read status from file (file-based since hooks are detached processes)
	local status_data = read_claude_status(pane.pane_id)
	local status = status_data and status_data.status or nil
	local start_time = status_data and status_data.start_time or nil

	-- Get title
	local title = tab.tab_title ~= "" and tab.tab_title or pane.title
	title = title:gsub("^✳%s*", "") -- Remove ✳ prefix if present

	-- If no Claude status file, show plain tab title
	if not status then
		return title
	end

	-- Get icon and color for status
	local icon = status_icons[status] or status_icons.unknown
	local color = agent_colors[status] or agent_colors.unknown

	-- Format elapsed time for running/blocked/waiting states
	local elapsed_str = ""
	if status == "running" or status == "blocked" or status == "waiting" then
		local elapsed = format_elapsed(start_time)
		if elapsed then
			elapsed_str = string.format(" (%s)", elapsed)
		end
	end

	-- Return formatted tab title with colors
	return wezterm.format({
		{ Foreground = { Color = color } },
		{ Text = icon .. " " },
		{ Foreground = { Color = agent_colors.fg } },
		{ Text = title },
		{ Foreground = { Color = agent_colors.muted } },
		{ Text = elapsed_str },
	})
end)

-- Cursor settings - steady, no blinking
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

-- Performance settings
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 30
config.status_update_interval = 100 -- 100ms polling for file-based status

-- macOS specific - allow Cmd+click for URLs
config.bypass_mouse_reporting_modifiers = "CMD"

-- QuickSelect patterns
config.quick_select_patterns = {
	"https?://\\S+", -- URLs
	"[~/][^\\s]+", -- File paths
	"\\b[0-9a-f]{7,40}\\b", -- Git SHAs
	"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", -- UUIDs
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Status Bar - Show Agent Summary, Workspace & Process                 ║
-- ╚══════════════════════════════════════════════════════════════════════╝
wezterm.on("update-right-status", function(window, _)
	-- Periodically clean up stale status files
	cleanup_stale_status_files()

	-- Count Claude agents by state across all panes (file-based status)
	local running, blocked, waiting, idle = 0, 0, 0, 0
	for _, tab in ipairs(window:mux_window():tabs()) do
		for _, p in ipairs(tab:panes()) do
			local status_data = read_claude_status(p:pane_id())
			local status = status_data and status_data.status

			if status == "running" then
				running = running + 1
			elseif status == "blocked" then
				blocked = blocked + 1
			elseif status == "waiting" then
				waiting = waiting + 1
			elseif status == "idle" then
				idle = idle + 1
			end
		end
	end

	-- Build colored agent summary using wezterm.format
	local agent_parts = {}
	local total = running + blocked + waiting + idle
	if total > 0 then
		if running > 0 then
			table.insert(agent_parts, { Foreground = { Color = agent_colors.running } })
			table.insert(agent_parts, { Text = "🤖" .. running })
		end
		if blocked > 0 then
			table.insert(agent_parts, { Foreground = { Color = agent_colors.blocked } })
			table.insert(agent_parts, { Text = " 🔐" .. blocked })
		end
		if waiting > 0 then
			table.insert(agent_parts, { Foreground = { Color = agent_colors.waiting } })
			table.insert(agent_parts, { Text = " 🔔" .. waiting })
		end
		if idle > 0 then
			table.insert(agent_parts, { Foreground = { Color = agent_colors.idle } })
			table.insert(agent_parts, { Text = " ⏸️" .. idle })
		end
		table.insert(agent_parts, { Foreground = { Color = agent_colors.fg } })
		table.insert(agent_parts, { Text = " | " })
	end

	local process_name = window:active_pane():get_foreground_process_name() or ""
	process_name = process_name:gsub("%.exe$", "")

	local leader_active = window:leader_is_active() and "LEADER | " or ""

	local workspace = window:active_workspace() or ""
	if workspace ~= "" then
		workspace = "[" .. workspace .. "] | "
	end

	local domain_name = window:active_pane():get_domain_name() or "local"
	local domain = "[" .. domain_name .. "] | "

	-- Combine formatted agent summary with plain text
	local plain_text = domain .. workspace .. leader_active .. process_name
	table.insert(agent_parts, { Foreground = { Color = agent_colors.fg } })
	table.insert(agent_parts, { Text = plain_text })

	window:set_right_status(wezterm.format(agent_parts))
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Key Bindings                                                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.keys = {-- Basic operations
	{
		key = "c",
		mods = "CMD",
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action({ SendString = "\x1b\r" }),
	},
	{
		key = "v",
		mods = "CMD",
		action = act.PasteFrom("Clipboard"),
	},
	{
		key = "+",
		mods = "CTRL",
		action = act.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CTRL",
		action = act.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CTRL",
		action = act.ResetFontSize,
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- Pane Navigation & Management (Vim-style with Leader)
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},
	{
		key = "q",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = false }),
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- Tab Management
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "t",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "]",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "b",
		mods = "LEADER",
		action = act.ShowTabNavigator,
	},
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename Tab",
			action = wezterm.action_callback(function(window, _, line)
				if line and line ~= "" then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "H",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(-1),
	},
	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(1),
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- Workspace Management
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "w",
		mods = "LEADER",
		action = act.ShowLauncherArgs({ flags = "WORKSPACES" }),
	},
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Switch to workspace:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "R",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Rename workspace:",
			action = wezterm.action_callback(function(window, _, line)
				local current_workspace = window:active_workspace()
				if current_workspace and line and line ~= "" then
					wezterm.mux.rename_workspace(current_workspace, line)
				end
			end),
		}),
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- Session Management
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "a",
		mods = "LEADER",
		action = act.AttachDomain("unix"),
	},
	{
		key = "d",
		mods = "LEADER",
		action = act.DetachDomain({ DomainName = "unix" }),
	},
	{
		-- Nuclear reset: Quit app, kill mux server, clean all state files
		key = "X",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			-- Spawn background process to clean up after WezTerm quits
			wezterm.background_child_process({
				"zsh",
				"-c",
				[[
          sleep 0.5
          pkill -9 -f "wezterm-mux-server" 2>/dev/null
          rm -f ~/.local/share/wezterm/sock
          rm -f ~/.local/share/wezterm/gui-sock-*
          rm -f ~/.local/share/wezterm/pid
          rm -f ~/.local/share/wezterm/default-*
          rm -f ~/.local/share/wezterm/wezterm-gui-log-*.txt
          rm -f ~/.local/share/wezterm/wezterm-log-*.txt
          rm -rf ~/.cache/claude-status
        ]],
			})
			-- Quit WezTerm (closes all windows gracefully)
			window:perform_action(act.QuitApplication, pane)
		end),
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- Launch Menu
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "p",
		mods = "LEADER",
		action = act.ShowLauncher,
	},

	-- ═══════════════════════════════════════════════════════════════════
	-- QuickSelect & Scrolling
	-- ═══════════════════════════════════════════════════════════════════
	{
		key = "Space",
		mods = "LEADER",
		action = act.QuickSelect,
	},
	{
		key = "PageUp",
		mods = "SHIFT",
		action = act.ScrollByPage(-1),
	},
	{
		key = "PageDown",
		mods = "SHIFT",
		action = act.ScrollByPage(1),
	},
	{
		key = "k",
		mods = "CMD",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Launch Menu                                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.launch_menu = {
	{
		label = "Shell",
		args = { "zsh", "-l" },
	},
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Agent Dashboard - View all Claude agents across workspaces           ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Priority order for agent status (attention-needed first)
local status_priority = {
	blocked = 1, -- Needs permission
	waiting = 2, -- Needs user input
	running = 3, -- Working
	idle = 4, -- Done
	unknown = 5, -- Unknown state
}

-- Collect all Claude agents with metadata (file-based status)
local function get_agents()
	local agents = {}

	-- Defensive: check mux.all_windows() exists and returns valid data
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

				-- Read status from file
				local status_data = read_claude_status(pane_id)

				-- Check if this is a Claude Code pane:
				-- 1. Has status file (set by our hooks), OR
				-- 2. Title starts with ✳, OR
				-- 3. Title contains "claude"
				local has_status_file = status_data ~= nil
				local has_claude_title = title:match("^✳") or title:lower():match("claude")

				if has_status_file or has_claude_title then
					local status = status_data and status_data.status or "unknown"
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
						status = status,
						start_time = start_time,
						priority = status_priority[status] or 5,
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
local function get_agent_dashboard_choices()
	local agents = get_agents()
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
						{ Foreground = { Color = agent_colors.muted } },
						{ Text = sep_label },
					}),
				})
			end
			last_status = agent.status
		end

		-- Format elapsed time
		local elapsed_str = ""
		if agent.start_time then
			local elapsed = format_elapsed(agent.start_time)
			if elapsed then
				elapsed_str = " (" .. elapsed .. ")"
			end
		end

		-- Get status icon and color
		local icon = status_icons[agent.status] or status_icons.unknown
		local color = agent_colors[agent.status] or agent_colors.unknown

		-- Build formatted label
		local label_parts = {
			{ Foreground = { Color = color } },
			{ Text = icon .. " " },
			{ Foreground = { Color = agent_colors.muted } },
			{ Text = "[" .. agent.workspace .. "] " },
			{ Foreground = { Color = agent_colors.fg } },
			{ Text = agent.title },
			{ Foreground = { Color = agent_colors.muted } },
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

-- Agent Dashboard action (wrapped in pcall for error visibility)
-- Pattern: Event-based monitoring (from resurrect.wezterm)
local agent_dashboard = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local choices, counts = get_agent_dashboard_choices()

		-- Calculate total for logging
		local total = counts.blocked + counts.waiting + counts.running + counts.idle
		wezterm.log_info("claude-agent: Dashboard opened, found " .. total .. " agents")

		-- Emit custom event for monitoring
		wezterm.emit("claude-agent.dashboard-opened", total, counts)

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
						return -- Ignore separator clicks
					end

					-- Parse the id: "tab_id:pane_id:workspace"
					local tab_id, pane_id, workspace = id:match("(%d+):(%d+):(.+)")
					tab_id = tonumber(tab_id)
					pane_id = tonumber(pane_id)

					-- Switch to workspace first
					if workspace then
						inner_window:perform_action(act.SwitchToWorkspace({ name = workspace }), inner_pane)
					end

					-- Then activate the specific pane
					if pane_id then
						wezterm.run_child_process({
							"/opt/homebrew/bin/wezterm",
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
		-- Emit error event for custom handling
		wezterm.emit("claude-agent.error", "dashboard", tostring(err))
	end
end)

-- Jump to next agent that needs attention (blocked or waiting)
local jump_to_next_waiting = wezterm.action_callback(function(window, pane)
	local ok, err = pcall(function()
		local agents = get_agents()
		wezterm.log_info("claude-agent: Jump looking for attention-needed agents in " .. #agents .. " total")

		-- Find first agent that needs attention
		for _, agent in ipairs(agents) do
			if agent.status == "blocked" or agent.status == "waiting" then
				wezterm.log_info("claude-agent: Jumping to " .. agent.status .. " agent in " .. (agent.workspace or "?"))

				-- Switch to workspace
				if agent.workspace then
					window:perform_action(act.SwitchToWorkspace({ name = agent.workspace }), pane)
				end

				-- Activate the pane
				if agent.pane_id then
					wezterm.run_child_process({
						"/opt/homebrew/bin/wezterm",
						"cli",
						"activate-pane",
						"--pane-id",
						tostring(agent.pane_id),
					})
				end

				window:toast_notification(
					"Agent Found",
					string.format("%s in %s", status_icons[agent.status] or "?", agent.workspace or "?"),
					nil,
					2000
				)
				return
			end
		end

		window:toast_notification("No Agents", "No agents need attention", nil, 2000)
	end)

	if not ok then
		window:toast_notification("Jump Error", tostring(err), nil, 5000)
		wezterm.log_error("claude-agent: Jump error: " .. tostring(err))
		wezterm.emit("claude-agent.error", "jump", tostring(err))
	end
end)

-- Add Agent Dashboard keybinding (Leader + g for "agents")
table.insert(config.keys, {
	key = "g",
	mods = "LEADER",
	action = agent_dashboard,
})

-- Add Jump to Next Waiting keybinding (Leader + n for "next")
table.insert(config.keys, {
	key = "n",
	mods = "LEADER",
	action = jump_to_next_waiting,
})

return config
