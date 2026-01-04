-- claude-agent/colors.lua - Tokyo Night color palette for agent status
local M = {}

-- Status colors (Tokyo Night)
M.status = {
	idle = "#565f89", -- Gray
	running = "#7aa2f7", -- Blue
	blocked = "#ff9e64", -- Orange
	waiting = "#e0af68", -- Yellow
	unknown = "#565f89", -- Gray
}

-- UI colors
M.ui = {
	fg = "#c0caf5", -- Default text
	muted = "#565f89", -- Muted text
}

-- Status icons (Antigravity-style)
M.icons = {
	idle = "⏸️",
	running = "🤖",
	blocked = "🔐",
	waiting = "🔔",
	unknown = "⚪",
}

return M
