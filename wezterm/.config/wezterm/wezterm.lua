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
	-- NOTE: Ctrl+scroll zoom removed - too easy to trigger accidentally with Ctrl+A
	-- Use Ctrl+/- or Ctrl+0 for font size changes instead
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
	-- Extract just the binary name (remove path and extension)
	local binary = process:gsub(".*/", ""):gsub("%.exe$", "")
	-- Match exact "claude" binary name to avoid false positives
	if binary == "claude" then
		window:toast_notification("Claude Code", "Agent ready for input", nil, 4000)
	end
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Performance & Cursor Settings                                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 30

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
-- ║ Key Bindings                                                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.keys = {
	-- Basic operations
	{
		key = "c",
		mods = "CMD",
		action = act.CopyTo("Clipboard"),
	},
	-- Shift+Enter sends ESC+Enter (useful for some apps that need literal newline)
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
          rm -f /tmp/rehoboam.sock
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

return config
