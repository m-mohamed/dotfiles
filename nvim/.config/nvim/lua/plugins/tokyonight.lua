-- Tokyo Night theme configuration for Neovim
-- Matches SketchyBar aesthetic for complete unixporn setup

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",              -- night, storm, day, or moon
      transparent = false,          -- Set to true for transparent background
      terminal_colors = true,       -- Configure terminal colors
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",          -- dark, transparent, normal
        floats = "dark",            -- dark, transparent, normal
      },
      sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,

      -- Custom colors to match SketchyBar
      on_colors = function(colors)
        -- Match Tokyo Night colors from SketchyBar
        colors.bg = "#1a1b26"
        colors.bg_dark = "#16161e"
        colors.bg_float = "#16161e"
        colors.bg_sidebar = "#16161e"
        colors.fg = "#c0caf5"
        colors.fg_dark = "#9aa5ce"
        colors.blue = "#7aa2f7"
        colors.cyan = "#7dcfff"
        colors.green = "#9ece6a"
        colors.orange = "#e0af68"
        colors.red = "#f7768e"
        colors.magenta = "#bb9af7"
      end,

      on_highlights = function(hl, c)
        -- Customize highlights for better visibility
        hl.CursorLine = { bg = "#24283b" }
        hl.LineNr = { fg = "#565f89" }
        hl.CursorLineNr = { fg = "#7aa2f7", bold = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
