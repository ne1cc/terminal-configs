-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Dynamic soft text-wrapping for all Markdown files
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_dynamic_wrap", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- Break at whole words (not mid-word)
    vim.opt_local.breakindent = true -- Preserve indentation on wrapped lines
    vim.opt_local.breakindentopt = "shift:2,min:20"
    vim.opt_local.showbreak = "↳ " -- Subtle wrapped line indicator
    vim.opt_local.conceallevel = 2 -- Clean markdown rendering
  end,
})
