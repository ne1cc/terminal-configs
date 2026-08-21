-- Automatically reload files changed outside of Neovim immediately
vim.o.autoread = true

-- Ensure ~/go/bin is in PATH for tools like sqls
vim.env.PATH = vim.fn.expand("$HOME/go/bin") .. ":" .. vim.env.PATH

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

-- Force window separators, fillchars, and transparent backgrounds
vim.opt.fillchars:append({
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
})

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = function()
    vim.cmd([[
      highlight Normal guibg=none ctermbg=none
      highlight NonText guibg=none ctermbg=none
      highlight NormalNC guibg=none ctermbg=none
      highlight WinSeparator guifg=#7aa2f7 gui=bold ctermfg=blue
      highlight VertSplit guifg=#7aa2f7 gui=bold ctermfg=blue
      highlight TabLineFill guibg=none
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

-- Add Homebrew fzf to Neovim runtimepath if installed
if vim.fn.isdirectory("/opt/homebrew/opt/fzf") == 1 then
  vim.opt.rtp:append("/opt/homebrew/opt/fzf")
end

-- Keymap to toggle buffer modifiable state (fixes "cannot make changes modifiable is off")
vim.keymap.set("n", "<leader>um", function()
  vim.bo.modifiable = not vim.bo.modifiable
  vim.notify("Buffer modifiable: " .. tostring(vim.bo.modifiable), vim.log.levels.INFO)
end, { desc = "Toggle Buffer Modifiable" })

-- Cut content after cursor in Insert/Command Mode (Alt+K)
vim.keymap.set({ "i", "c" }, "<A-k>", "<C-o>d$", { desc = "Cut content after cursor to clipboard" })
vim.keymap.set({ "i", "c" }, "<A-K>", "<C-o>d$", { desc = "Cut content after cursor to clipboard" })

-- Clear content after cursor in Insert Mode (Ctrl+K)
vim.keymap.set({ "i", "c" }, "<C-k>", "<C-o>D", { desc = "Clear content after cursor" })
vim.keymap.set({ "i", "c" }, "<C-K>", "<C-o>D", { desc = "Clear content after cursor" })

-- Image Gallery Buffer Navigation (j/k or ]i/[i to cycle next/prev image in folder)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.svg" },
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "j", ":bnext<CR>", opts)
    vim.keymap.set("n", "]i", ":bnext<CR>", opts)
    vim.keymap.set("n", "k", ":bprevious<CR>", opts)
    vim.keymap.set("n", "[i", ":bprevious<CR>", opts)
  end,
})

-- Open PDF under cursor or companion PDF in MuPDF
local function open_in_mupdf()
  -- 1. Check if the string under the cursor is a path/file
  local cfile = vim.fn.expand("<cfile>")
  local target = ""

  if cfile ~= "" and vim.fn.filereadable(cfile) == 1 and cfile:match("%.pdf$") then
    target = cfile
  else
    -- 2. Fallback: check if the current file itself is a PDF or has a corresponding .pdf
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file:match("%.pdf$") then
      target = current_file
    else
      -- Check if companion file exists (e.g. paper.tex -> paper.pdf, document.typ -> document.pdf)
      local companion_pdf = vim.fn.expand("%:p:r") .. ".pdf"
      if vim.fn.filereadable(companion_pdf) == 1 then
        target = companion_pdf
      end
    end
  end

  if target == "" or vim.fn.filereadable(target) == 0 then
    vim.notify("No valid PDF found to open.", vim.log.levels.WARN)
    return
  end

  -- Launch MuPDF asynchronously in the background
  vim.fn.jobstart({ "mupdf", vim.fn.fnamemodify(target, ":p") }, { detach = true })
  vim.notify("Opened in MuPDF: " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>pdf", open_in_mupdf, { desc = "Open PDF under cursor/buffer in MuPDF", silent = true })
