-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Helper function to open file/URL in system viewer silently (suppresses error popups on invalid characters/paths)
local function open_system(path)
  local cmd
  if vim.fn.has("win32") == 1 then
    cmd = { "cmd.exe", "/c", "start", '""', path }
  elseif vim.fn.has("mac") == 1 then
    cmd = { "open", path }
  else
    cmd = { "xdg-open", path }
  end
  vim.fn.jobstart(cmd, { detach = true })
end

-- Maps <Leader>gx to open the current file in the system default viewer silently
vim.keymap.set("n", "<Leader>gx", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    open_system(file)
  else
    vim.notify("No file name for current buffer", vim.log.levels.WARN)
  end
end, { desc = "Open file in system viewer silently" })

-- Maps gx in Normal mode to open the file or URL under the cursor silently (handling cases like "|" gracefully)
vim.keymap.set("n", "gx", function()
  local file = vim.fn.expand("<cfile>")
  if not file or file == "" or file:match("^%s+$") or file == "|" then return end
  
  -- Handle GitHub shorthand (e.g., user/repo)
  if file:match("^[%w%-%.]+/[%w%-%.]+$") and vim.fn.filereadable(file) == 0 then
    file = "https://github.com/" .. file
  end

  open_system(file)
end, { desc = "Open file or URL under cursor silently" })

-- Maps gx in Visual/Select mode to open the selected text silently
vim.keymap.set("x", "gx", function()
  local old_reg = vim.fn.getreg('"')
  vim.cmd('normal! y')
  local selection = vim.fn.getreg('"')
  vim.fn.setreg('"', old_reg)
  selection = selection:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
  if selection ~= "" and selection ~= "|" then
    open_system(selection)
  end
end, { desc = "Open selected file or URL silently" })



-- Maximize / Zoom toggle for the current window split
vim.keymap.set("n", "<leader>wm", "<cmd>WindowsMaximize<cr>", { desc = "Maximize / Zoom Window Split" })

local function resolve_companion_file(extension)
  local cfile = vim.fn.expand("<cfile>")
  if cfile ~= "" and vim.fn.filereadable(cfile) == 1 and cfile:match("%." .. extension .. "$") then
    return cfile
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file:match("%." .. extension .. "$") then
    return current_file
  end

  local companion = vim.fn.expand("%:p:r") .. "." .. extension
  if vim.fn.filereadable(companion) == 1 then
    return companion
  end

  return nil
end

local function open_in_mupdf()
  local target = resolve_companion_file("pdf")
  if not target then
    vim.notify("No valid PDF found to open.", vim.log.levels.WARN)
    return
  end

  vim.fn.jobstart({ "mupdf", vim.fn.fnamemodify(target, ":p") }, { detach = true })
  vim.notify("Opened in MuPDF: " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
end

local function open_in_omnireader()
  local target = resolve_companion_file("epub")
  if not target then
    vim.notify("No valid EPUB found to open.", vim.log.levels.WARN)
    return
  end

  local absolute_target = vim.fn.fnamemodify(target, ":p")
  if vim.fn.has("mac") == 1 then
    vim.fn.jobstart({ "open", "-a", "OmniReader", absolute_target }, { detach = true })
  elseif vim.fn.executable("xdg-open") == 1 then
    vim.fn.jobstart({ "xdg-open", absolute_target }, { detach = true })
  else
    vim.notify("No EPUB viewer found (OmniReader on macOS, xdg-open on Linux).", vim.log.levels.WARN)
    return
  end

  vim.notify("Opened EPUB: " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>op", open_in_mupdf, { desc = "Open PDF under cursor/buffer in MuPDF", silent = true })
vim.keymap.set("n", "<leader>oe", open_in_omnireader, { desc = "Open EPUB under cursor/buffer in OmniReader", silent = true })

local function is_markdown(path)
  return path:match("%.md$") or path:match("%.markdown$")
end

local function resolve_markdown_file()
  local cfile = vim.fn.expand("<cfile>")
  if cfile ~= "" and vim.fn.filereadable(cfile) == 1 and is_markdown(cfile) then
    return cfile
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= "" and is_markdown(current_file) then
    return current_file
  end

  for _, ext in ipairs({ "md", "markdown" }) do
    local companion = vim.fn.expand("%:p:r") .. "." .. ext
    if vim.fn.filereadable(companion) == 1 then
      return companion
    end
  end

  return nil
end

local function open_in_one_markdown()
  local target = resolve_markdown_file()
  if not target then
    vim.notify("No valid Markdown file found to open.", vim.log.levels.WARN)
    return
  end

  local absolute_target = vim.fn.fnamemodify(target, ":p")
  if vim.fn.has("mac") == 1 then
    vim.fn.jobstart({ "open", "-a", "One Markdown", absolute_target }, { detach = true })
  elseif vim.fn.executable("glow") == 1 then
    vim.fn.jobstart({ "glow", "-p", absolute_target }, { detach = true })
  elseif vim.fn.executable("xdg-open") == 1 then
    vim.fn.jobstart({ "xdg-open", absolute_target }, { detach = true })
  else
    vim.notify("No Markdown viewer found (One Markdown on macOS, glow/xdg-open on Linux).", vim.log.levels.WARN)
    return
  end

  vim.notify("Opened in One Markdown: " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
end

local function open_in_marktext()
  local target = resolve_markdown_file()
  if not target then
    vim.notify("No valid Markdown file found to open.", vim.log.levels.WARN)
    return
  end

  local absolute_target = vim.fn.fnamemodify(target, ":p")
  local launched = false

  if vim.fn.has("mac") == 1 then
    vim.fn.jobstart({ "open", "-na", "Mark Text", "--args", absolute_target }, { detach = true })
    launched = true
  elseif vim.fn.executable("marktext") == 1 then
    vim.fn.jobstart({ "marktext", absolute_target }, { detach = true })
    launched = true
  elseif vim.fn.executable("flatpak") == 1 then
    vim.fn.jobstart({
      "flatpak",
      "run",
      "com.github.marktext.marktext",
      absolute_target,
    }, { detach = true })
    launched = true
  end

  if not launched then
    vim.notify("Mark Text not found (install Mark Text or marktext CLI).", vim.log.levels.WARN)
    return
  end

  vim.notify("Opened in Mark Text (new window): " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>om", open_in_one_markdown, { desc = "Open Markdown under cursor/buffer in One Markdown", silent = true })
vim.keymap.set("n", "<leader>mt", open_in_marktext, { desc = "Open Markdown under cursor/buffer in Mark Text (new window)", silent = true })
