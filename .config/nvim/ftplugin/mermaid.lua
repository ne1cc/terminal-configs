-- ftplugin for mermaid and mmd files
local opts = { silent = true, buffer = true }
local map = vim.keymap.set

-- Browser preview for mermaid
map("n", "<leader>mp", function()
  vim.cmd("MarkdownPreviewToggle")
end, vim.tbl_extend("force", opts, { desc = "Mermaid browser preview" }))

-- Diagram hover preview (dedicated clean tab at cursor; press 'q' to exit, 'o' to open externally)
map("n", "<leader>md", function()
  require("diagram").show_diagram_hover()
end, vim.tbl_extend("force", opts, { desc = "Show diagram in dedicated tab" }))

-- Open diagram directly in macOS system viewer (Preview)
map("n", "<leader>mo", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local source = table.concat(lines, "\n")
  if vim.trim(source) == "" then
    vim.notify("Mermaid buffer is empty", vim.log.levels.WARN, { title = "Diagram" })
    return
  end

  local renderer = require("diagram/renderers/mermaid")
  local config_file = vim.fn.expand("~/.config/nvim/mermaid.json")
  local pptr_file = vim.fn.expand("~/.puppeteerrc.json")
  local cli_args = {}
  if vim.fn.filereadable(config_file) == 1 then
    table.insert(cli_args, "-c")
    table.insert(cli_args, config_file)
  end
  if vim.fn.filereadable(pptr_file) == 1 then
    table.insert(cli_args, "-p")
    table.insert(cli_args, pptr_file)
  end

  local options = {
    background = "#1a1b26",
    theme = "dark",
    scale = 3.0,
    width = 1800,
    cli_args = cli_args,
  }

  vim.notify("Rendering high-res Mermaid diagram...", vim.log.levels.INFO, { title = "Diagram" })
  local result = renderer.render(source, options)
  if not result then return end

  local function open_file()
    if vim.fn.filereadable(result.file_path) == 1 then
      vim.ui.open(result.file_path)
      vim.notify("Opened diagram in system viewer", vim.log.levels.INFO, { title = "Diagram" })
    else
      vim.notify("Diagram file not found: " .. result.file_path, vim.log.levels.ERROR, { title = "Diagram" })
    end
  end

  if result.job_id then
    local timer = vim.loop.new_timer()
    if not timer then return end
    timer:start(
      0,
      100,
      vim.schedule_wrap(function()
        local wait_result = vim.fn.jobwait({ result.job_id }, 0)
        if wait_result[1] ~= -1 then
          if timer:is_active() then timer:stop() end
          if not timer:is_closing() then
            timer:close()
            open_file()
          end
        end
      end)
    )
  else
    open_file()
  end
end, vim.tbl_extend("force", opts, { desc = "Open diagram in system viewer" }))

-- Toggle in-buffer rendering (opaque background)
map("n", "<leader>mb", function()
  local diag = require("diagram")
  if _G._diagram_in_buffer_rendered then
    diag.clear()
    _G._diagram_in_buffer_rendered = false
    vim.notify("Diagram in-buffer cleared", vim.log.levels.INFO, { title = "Diagram" })
  else
    diag.render()
    _G._diagram_in_buffer_rendered = true
    vim.notify("Diagram rendered in-buffer", vim.log.levels.INFO, { title = "Diagram" })
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle diagram in-buffer" }))

-- Clear image overlays
map("n", "<leader>ic", function()
  if pcall(require, "image") then
    require("image").clear()
  end
  if pcall(require, "diagram") then
    require("diagram").clear()
  end
  local clear_seq = "\x1b_Ga=d,d=A\x1b\\"
  if vim.env.TMUX then
    clear_seq = "\x1bPtmux;\x1b\x1b_Ga=d,d=A\x1b\x1b\\\x1b\\"
  end
  io.stdout:write(clear_seq)
  io.stdout:flush()
  vim.cmd("redraw!")
  vim.notify("Cleared all image and diagram overlays", vim.log.levels.INFO, { title = "Image Overlays" })
end, vim.tbl_extend("force", opts, { desc = "Clear image overlays" }))
