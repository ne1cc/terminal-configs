local function toggle_strikethrough_visual()
  -- Save visual selection to register 'z'
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  local new_text

  -- Check if text is surrounded by ~~
  if text:sub(1, 2) == "~~" and text:sub(-2) == "~~" then
    new_text = text:sub(3, -3)
  else
    new_text = "~~" .. text .. "~~"
  end

  vim.fn.setreg("z", new_text)
  vim.cmd('normal! gv"zp')
end

local function toggle_strikethrough_normal()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  -- Find pattern ~~...~~ around cursor
  local s_start, s_end
  local search_from = 1
  while true do
    local start_idx, end_idx = line:find("~~.-~~", search_from)
    if not start_idx then break end
    if col >= start_idx and col <= end_idx then
      s_start, s_end = start_idx, end_idx
      break
    end
    search_from = end_idx + 1
  end

  if s_start and s_end then
    -- Remove ~~
    local inner = line:sub(s_start + 2, s_end - 2)
    local new_line = line:sub(1, s_start - 1) .. inner .. line:sub(s_end + 1)
    vim.api.nvim_set_current_line(new_line)
  else
    -- Fallback: wrap word under cursor with ~~
    vim.cmd("normal! viw")
    toggle_strikethrough_visual()
  end
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>~"] = { toggle_strikethrough_normal, desc = "Toggle strikethrough" },
        ["<Leader>ms"] = { toggle_strikethrough_normal, desc = "Toggle strikethrough" },
      },
      v = {
        ["<Leader>~"] = { toggle_strikethrough_visual, desc = "Toggle strikethrough" },
        ["<Leader>ms"] = { toggle_strikethrough_visual, desc = "Toggle strikethrough" },
      },
    },
  },
}



