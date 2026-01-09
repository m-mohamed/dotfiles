return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  opts = {
    preset = "obsidian", -- Obsidian-style rendering for all markdown
    checkbox = {
      enabled = false, -- Disabled to use obsidian.nvim checkbox rendering instead
      unchecked = {
        icon = "󰄱 ",
        highlight = "RenderMarkdownUnchecked",
      },
      checked = {
        icon = "✅ ",
        highlight = "RenderMarkdownChecked",
      },
    },
  },
  -- Set green color for checked checkboxes
  init = function()
    vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#10b981" })
  end,
  -- Add checkbox insert keybinding
  keys = {
    {
      "<leader>o-",
      function()
        local line = vim.api.nvim_get_current_line()
        -- Don't add if line already has a checkbox
        if line:match("%[[ x]%]") then
          return
        end

        -- Match: (indent)(bullet)(space)(rest of line)
        local indent, bullet, rest = line:match("^(%s*)([-*+])%s*(.*)")

        if indent and bullet then
          -- Line has a bullet: insert checkbox after bullet
          vim.api.nvim_set_current_line(indent .. bullet .. " [ ] " .. rest)
        else
          -- Line has no bullet: add bullet + checkbox at start (preserving indent if any)
          local leading_space = line:match("^(%s*)")
          local text = line:match("^%s*(.*)")
          vim.api.nvim_set_current_line(leading_space .. "- [ ] " .. text)
        end
      end,
      desc = "Insert checkbox",
      ft = "markdown",
    },
  },
}
