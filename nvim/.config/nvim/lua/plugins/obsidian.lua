return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release
    ft = "markdown", -- lazy-load on markdown files
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      -- Workspace configuration
      workspaces = {
        {
          name = "slipbox",
          path = "~/obsidian/slipbox",
        },
      },

      -- Daily notes configuration
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %d, %Y",
        default_tags = { "daily-notes" },
        template = "daily.md",
      },

      -- Templates configuration
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {},
      },

      -- Completion configuration (blink.cmp)
      completion = {
        nvim_cmp = false, -- disable nvim-cmp completion
        min_chars = 2,
      },

      -- Note ID generation (matches your existing pattern)
      note_id_func = function(title)
        -- If title is provided, use it as-is for the filename
        if title ~= nil then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- Generate timestamp-based ID for new notes without title
          return tostring(os.time())
        end
      end,

      -- Note frontmatter configuration
      note_frontmatter_func = function(note)
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- Preserve any existing metadata
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,

      -- Picker configuration (Snacks)
      picker = {
        name = "snacks.picker",
      },

      -- UI configuration - enabled for checkbox functionality
      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },
      checkboxes = {
        [" "] = { char = "TODO", hl_group = "ObsidianTodo", order = 1 },
        ["x"] = { char = "DONE", hl_group = "ObsidianDone", order = 2 },
        [">"] = { char = "FORWARDED", hl_group = "ObsidianRightArrow", order = 3 },
        ["~"] = { char = "CANCELLED", hl_group = "ObsidianTilde", order = 4 },
      },

      -- Additional options
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url }) -- macOS
      end,

      -- Disable some features that conflict with LazyVim
      disable_frontmatter = false,

      -- Image pasting configuration
      attachments = {
        img_folder = "assets/imgs",
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
    },

    -- Keymaps following LazyVim conventions
    keys = {
      -- Daily notes workflow (most common actions)
      {
        "<leader>ot",
        "<cmd>ObsidianToday<cr>",
        desc = "Open today's daily note",
      },
      {
        "<leader>oy",
        "<cmd>ObsidianYesterday<cr>",
        desc = "Open yesterday's daily note",
      },
      {
        "<leader>om",
        "<cmd>ObsidianTomorrow<cr>",
        desc = "Open tomorrow's daily note",
      },
      {
        "<leader>od",
        "<cmd>ObsidianDailies<cr>",
        desc = "Browse daily notes",
      },

      -- Note management
      {
        "<leader>on",
        "<cmd>ObsidianNew<cr>",
        desc = "Create new note",
      },
      {
        "<leader>oo",
        "<cmd>ObsidianQuickSwitch<cr>",
        desc = "Quick switch to note",
      },
      {
        "<leader>os",
        "<cmd>ObsidianSearch<cr>",
        desc = "Search notes",
      },
      {
        "<leader>of",
        "<cmd>ObsidianFollowLink<cr>",
        desc = "Follow link under cursor",
      },
      {
        "<leader>ob",
        "<cmd>ObsidianBacklinks<cr>",
        desc = "Show backlinks",
      },
      {
        "<leader>ol",
        "<cmd>ObsidianLinks<cr>",
        desc = "Show links in current note",
      },
      {
        "<leader>oc",
        "<cmd>ObsidianTOC<cr>",
        desc = "Table of contents",
      },

      -- Templates and media
      {
        "<leader>oT",
        "<cmd>ObsidianTemplate<cr>",
        desc = "Insert template",
      },
      {
        "<leader>op",
        "<cmd>ObsidianPasteImg<cr>",
        desc = "Paste image from clipboard",
      },

      -- Smart actions (only in markdown buffers)
      {
        "<cr>",
        function()
          return require("obsidian").util.smart_action()
        end,
        buffer = true,
        expr = true,
        desc = "Obsidian smart action",
        ft = "markdown",
      },

      -- Link navigation
      {
        "[o",
        function()
          return require("obsidian").util.gf_passthrough()
        end,
        buffer = true,
        expr = true,
        desc = "Navigate to previous link",
        ft = "markdown",
      },
      {
        "]o",
        function()
          return require("obsidian").util.gf_passthrough()
        end,
        buffer = true,
        expr = true,
        desc = "Navigate to next link",
        ft = "markdown",
      },

      -- Checkbox toggle
      {
        "<leader>ox",
        "<cmd>ObsidianToggleCheckbox<cr>",
        desc = "Toggle checkbox",
      },
    },
  },
}
