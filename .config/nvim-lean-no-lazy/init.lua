-- OPTIONS
local opt = vim.opt
-- Time in milliseconds to wait for a mapped sequence to complete
opt.timeoutlen = 300
opt.ttimeoutlen = 0
opt.updatetime = 250
-- UI Layout
opt.number = true
opt.relativenumber = true
opt.splitright = true
opt.splitbelow = true
opt.winborder = 'rounded'
opt.wrap = false
-- Tabs & Indentation (Industry Standard Defaults)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.autoindent = true
-- Autocompletion
opt.ignorecase = true
opt.smartcase = true
-- visual
opt.termguicolors = true
-- other
opt.swapfile = false
opt.undofile = true
opt.signcolumn = 'yes'
opt.incsearch = true
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- System Clipboard Integration
opt.clipboard = "unnamedplus"

-- PLUGINS
vim.pack.add({
  { src = 'https://github.com/echasnovski/mini.statusline' },
  { src = 'https://github.com/vague2k/vague.nvim' },
  { src = 'https://github.com/echasnovski/mini.pick' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/christoomey/vim-tmux-navigator' },
  { src = 'https://github.com/williamboman/mason.nvim' },
})
require('mini.pick').setup()
require('mini.statusline').setup()
require('mason').setup()
require('oil').setup({
  keymaps = {
    ["<Esc>"] = { "actions.close", mode = "n" },
  }
})
require('nvim-treesitter').setup({
  ensure_installed = { "cpp", "python", "cmake", "bash" },
  highlight = { enable = true },
  indent = { enable = true }
})

vim.lsp.enable({
  "lua_ls",
  "clangd",
  "basedpyright",
  "marksman",
  "texlab",
  "bashls",
})

-- KEYBINDS
vim.g.mapleader = ' '
vim.g.localleader = ' '
local map = vim.keymap.set
-- main
map('n', '<leader>s', '<cmd>update<CR><cmd>source<CR>', { silent = true, desc = "Update and Source Nvim Config" })
map('n', '<leader>w', '<cmd>write<CR>', { silent = true, desc = "Write Out Buffer" })
map('n', '<leader>q', '<cmd>quit<CR>', { silent = true, desc = "Quit" })
map('n', '<leader>lf', vim.lsp.buf.format, { silent = true, desc = "Language Format" })
-- navigation
map({ "n", "v", "x" }, "H", "^", { silent = true, desc = "Jump to First Non-Blank Character" })
map({ "n", "v", "x" }, "L", "$", { silent = true, desc = "Jump to Line Termination" })
map("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Scroll Downwards and Center Cursor" })
map("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Scroll Upwards and Center Cursor" })
map("n", "n", "nzzzv", { silent = true, desc = "Next Search Match and Center Cursor" })
map("n", "N", "Nzzzv", { silent = true, desc = "Previous Search Match and Center Cursor" })
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Translate Selected Block Downwards" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Translate Selected Block Upwards" })
-- pane managment
map("n", "<leader>|", "<cmd>vsplit<cr>", { silent = true, desc = "Split Window Vertically" })
map("n", "<leader>_", "<cmd>split<cr>", { silent = true, desc = "Split Window Horizontally" })
map("n", "<leader>x", "<cmd>close<cr>", { silent = true, desc = "Close Current Window" })
-- yanking
map({ "n", "v", "x" }, "<leader>y", '"+y', { silent = true, desc = "Yank Selection to System Clipboard" })
map({ "n", "v", "x" }, "<leader>d", '"+d', { silent = true, desc = "Delete Selection to System Clipboard" })
-- plugins
map("n", "<leader>e", "<cmd>Oil<CR>", { silent = true, desc = "Open Oil File Explorer" })
map("n", "<leader>f", "<cmd>Pick files<CR>", { silent = true, desc = "Fuzzy Find Workspace Files" })
map("n", "<leader>h", "<cmd>Pick help<CR>", { silent = true, desc = "Fuzzy Find Help Configurations" })

-- COLORS
vim.cmd('colorscheme vague')
