-- lua/lean/core/keymaps.lua
local key = vim.keymap

-- ==============================================================================
-- INTERNAL WINDOW MANAGEMENT (Symmetrical to tmux.conf)
-- ==============================================================================
key.set("n", "<leader>|", "<cmd>vsplit<cr>", { silent = true, desc = "Split Window Vertically" })
key.set("n", "<leader>_", "<cmd>split<cr>", { silent = true, desc = "Split Window Horizontally" })
key.set("n", "<leader>x", "<cmd>close<cr>", { silent = true, desc = "Close Current Window" })

-- ==============================================================================
-- BUFFER & SYSTEM COMMANDS
-- ==============================================================================
key.set("n", "<leader>w", "<cmd>write!<CR>", { silent = true, desc = "Save Current Buffer" })
key.set("n", "<leader>s", "<cmd>update!<CR><cmd>source<CR>", { silent = true, desc = "Save and Source Active File" })

-- ==============================================================================
-- REGISTER MANIPULATION (Yanking / Deleting to System Clipboard)
-- ==============================================================================
key.set({ "n", "v", "x" }, "<leader>y", '"+y', { silent = true, desc = "Yank Selection to System Clipboard" })
key.set({ "n", "v", "x" }, "<leader>d", '"+d', { silent = true, desc = "Delete Selection to System Clipboard" })

-- ==============================================================================
-- LINE BOUNDARY NAVIGATION
-- ==============================================================================
key.set({ "n", "v", "x" }, "H", "^", { silent = true, desc = "Jump to First Non-Blank Character" })
key.set({ "n", "v", "x" }, "L", "$", { silent = true, desc = "Jump to Line Termination" })

-- ==============================================================================
-- ISOLATED PLUGIN INTERFACES
-- ==============================================================================
key.set("n", "<leader>e", "<cmd>Oil<CR>", { silent = true, desc = "Open Oil File Explorer" })
key.set("n", "<leader>f", "<cmd>Pick files<CR>", { silent = true, desc = "Fuzzy Find Workspace Files" })
key.set("n", "<leader>h", "<cmd>Pick help<CR>", { silent = true, desc = "Fuzzy Find Help Configurations" })

-- Consistent Viewport Centering during high-velocity vertical searching
key.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Scroll Downwards and Center Cursor" })
key.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Scroll Upwards and Center Cursor" })
key.set("n", "n", "nzzzv", { silent = true, desc = "Next Search Match and Center Cursor" })
key.set("n", "N", "Nzzzv", { silent = true, desc = "Previous Search Match and Center Cursor" })

-- Visual Block Dragging (Symmetrical to shifting layout constructs)
key.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Translate Selected Block Downwards" })
key.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Translate Selected Block Upwards" })
