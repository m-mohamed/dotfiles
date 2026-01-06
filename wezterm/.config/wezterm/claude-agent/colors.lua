-- claude-agent/colors.lua - Color palette and icons for agent status
-- Pattern: tabline.wez theme system
local M = {}

-- Default theme: Tokyo Night
-- 4-state system: idle (inactive), working (processing), attention (needs you), compacting (context filling)
local default_theme = {
	-- Status colors
	status = {
		idle = "#565f89", -- Gray - session inactive
		working = "#7aa2f7", -- Blue - Claude processing
		attention = "#ff9e64", -- Orange - needs user input/permission
		compacting = "#e0af68", -- Yellow/amber - context compacting
		unknown = "#565f89", -- Gray - fallback
	},
	-- UI colors
	ui = {
		fg = "#c0caf5", -- Default text
		muted = "#565f89", -- Muted text
	},
}

-- Default icons
-- 4-state system: idle ⏸️, working 🤖, attention 🔔, compacting 🔄
local default_icons = {
	idle = "⏸️",
	working = "🤖",
	attention = "🔔",
	compacting = "🔄",
	unknown = "⚪",
}

-- Active theme (can be overridden)
M.status = {}
M.ui = {}
M.icons = {}

-- Deep merge helper
local function merge(base, overrides)
	local result = {}
	for k, v in pairs(base) do
		result[k] = v
	end
	if overrides then
		for k, v in pairs(overrides) do
			result[k] = v
		end
	end
	return result
end

-- Setup with optional theme overrides (tabline.wez pattern)
M.setup = function(opts)
	opts = opts or {}

	-- Apply theme overrides
	M.status = merge(default_theme.status, opts.status)
	M.ui = merge(default_theme.ui, opts.ui)
	M.icons = merge(default_icons, opts.icons)
end

-- Get current theme (tabline.wez pattern)
M.get_theme = function()
	return {
		status = M.status,
		ui = M.ui,
		icons = M.icons,
	}
end

-- Set theme with overrides (tabline.wez pattern)
M.set_theme = function(overrides)
	if overrides then
		if overrides.status then
			M.status = merge(M.status, overrides.status)
		end
		if overrides.ui then
			M.ui = merge(M.ui, overrides.ui)
		end
		if overrides.icons then
			M.icons = merge(M.icons, overrides.icons)
		end
	end
end

-- Initialize with defaults
M.setup()

return M
