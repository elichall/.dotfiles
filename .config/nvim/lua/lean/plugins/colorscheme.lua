-- lua/lean/plugins/colorscheme.lua
return {
  {
    "vague2k/vague.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "gmr458/vscode_modern_theme.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "D0nw0r/dark2026.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "rose-pine/neovim",
    lazy = false,
    priority = 1000,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "savq/melange-nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    optional = true,
    opts = { colorscheme = "lean_sync" },
  },
  {
    "lean_sync",
    dir = vim.fn.stdpath("config"), -- Mounts local path as a native package provider
    lazy = false,
    priority = 1000,                -- Forces immediate loading before editor interface draws
    config = function()
      vim.cmd("colorscheme lean_sync")
    end,
  },
}
