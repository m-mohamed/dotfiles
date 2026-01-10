local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Tmux Integration                                                     ║
-- ║ WezTerm as display layer, Tmux for session/pane management          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Launch tmux by default (attach to main session or create it)
config.default_prog = { "/opt/homebrew/bin/tmux", "new-session", "-A", "-s", "main" }

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Basic Settings                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.disable_default_key_bindings = true
config.font_size = 22
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.window_decorations = "RESIZE"
config.use_dead_keys = false
-- macOS Option/Alt key behavior: send Alt/Meta for Alt+key combinations
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.scrollback_lines = 10000
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Hide WezTerm tab bar (tmux handles this)
config.enable_tab_bar = false

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Color Scheme (Tokyo Night)                                          ║
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
}

config.color_schemes = {
	["TokyoNight"] = tokyo_night,
}
config.color_scheme = "TokyoNight"

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ Modern Terminal Features                                             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- GitHub shorthand pattern (org/repo#123 -> PR/issue link)
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
}

-- Disable audible bell
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
config.notification_handling = "AlwaysShow"

-- Bell event handler - convert terminal bells to toast notifications for Claude
wezterm.on("bell", function(window, pane)
	local process = pane:get_foreground_process_name() or ""
	local binary = process:gsub(".*/", ""):gsub("%.exe$", "")
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
-- ║ Minimal - tmux handles most navigation with Ctrl+a prefix           ║
-- ╚══════════════════════════════════════════════════════════════════════╝
config.keys = {
	-- Copy/Paste (macOS standard)
	{
		key = "c",
		mods = "CMD",
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "v",
		mods = "CMD",
		action = act.PasteFrom("Clipboard"),
	},
	-- Shift+Enter sends ESC+Enter (for literal newlines in some apps)
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action({ SendString = "\x1b\r" }),
	},
	-- Font size (Ctrl+/-)
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
	-- Clear scrollback (Cmd+k)
	{
		key = "k",
		mods = "CMD",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	-- QuickSelect (Cmd+Space)
	{
		key = "Space",
		mods = "CMD",
		action = act.QuickSelect,
	},
	-- Scrolling
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
}

return config
