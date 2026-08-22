-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Ergonomics & Cursor Management
opt.relativenumber = true -- Relative line numbers for fast vertical jumping
opt.scrolloff = 8 -- Keep 8 lines of context above and below cursor
opt.sidescrolloff = 8 -- Keep 8 columns of context horizontally
opt.cursorline = true -- Highlight active line
opt.signcolumn = "yes" -- Always show signcolumn to avoid layout jumps

-- Search & Case Sensitivity
opt.ignorecase = true -- Case-insensitive search by default
opt.smartcase = true -- Case-sensitive when search contains capitals
opt.hlsearch = true
opt.incsearch = true

-- Formatting & Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- System Clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard smoothly

-- Fast UI responsiveness
opt.updatetime = 200 -- Faster completion and gitsigns refresh
opt.timeoutlen = 300 -- Faster which-key triggers
