return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        split_side = "right", -- Right side vertical split
        split_width_percentage = 0.50, -- 50% width (default is 0.30)
      },
    },
    config = function(_, opts)
      -- Load the plugin with options
      require("claudecode").setup(opts)

      -- Add Ctrl-n for safe normal mode in Claude terminal
      -- This avoids the Esc Esc bug that can interrupt Claude tasks
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*claude*",
        callback = function()
          vim.keymap.set("t", "<C-n>", "<C-\\><C-n>", {
            buffer = true,
            desc = "Claude: Enter normal mode (safe - won't interrupt)",
          })
        end,
        desc = "Add Ctrl-n keybinding for Claude terminal normal mode",
      })
    end,
  },
}
