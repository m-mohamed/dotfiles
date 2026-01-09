-- Ensure nil_ls is managed outside Mason to avoid repeated failed installs.
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(server)
        return server ~= "nil_ls"
      end, opts.ensure_installed)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
          cmd = { "nil" }, -- expect nil from Homebrew/your PATH
        },
      },
    },
  },
}
