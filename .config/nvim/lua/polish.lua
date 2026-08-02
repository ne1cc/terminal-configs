-- Automatically reload files changed outside of Neovim immediately
vim.o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Force transparent backgrounds across all themes (critical for Ghostty frosted glass)
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = function()
    vim.cmd([[
      highlight Normal guibg=none ctermbg=none
      highlight NonText guibg=none ctermbg=none
      highlight NormalNC guibg=none ctermbg=none
    ]])
  end,
})

-- Enable line wrapping and word breaks for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Auto-restore persistence.nvim session on startup
local restore_group = vim.api.nvim_create_augroup("PersistenceAutoRestore", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = restore_group,
  nested = true,
  callback = function()
    -- Only auto-restore if Neovim was launched without path arguments or stdin piping
    local is_empty_args = vim.fn.argc() == 0
    local is_not_stdin = not vim.g.started_by_firenvim and vim.fn.line2byte(1) == -1

    if is_empty_args and is_not_stdin then
      require("persistence").load()
    end
  end,
})
