local M = {}

local function get_chrome_executable()
  if vim.env.PUPPETEER_EXECUTABLE_PATH and vim.fn.filereadable(vim.env.PUPPETEER_EXECUTABLE_PATH) == 1 then
    return vim.env.PUPPETEER_EXECUTABLE_PATH
  end
  local candidates = {
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      vim.env.PUPPETEER_EXECUTABLE_PATH = path
      return path
    end
  end
  return nil
end

get_chrome_executable()

local function get_mermaid_options()
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

  return {
    background = "#1a1b26", -- Opaque TokyoNight dark to match terminal
    theme = "dark",
    scale = 3.0,            -- Retina 300+ DPI high-resolution output
    width = 2400,           -- Extra-wide canvas to prevent label truncation
    cli_args = cli_args,
  }
end

local function get_buffer_diagrams(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if ft == "mermaid" or ft == "mmd" then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
    if vim.trim(content) == "" then return {} end
    return {
      {
        bufnr = bufnr,
        renderer_id = "mermaid",
        source = content,
        range = {
          start_row = 0,
          start_col = 0,
          end_row = math.max(0, #lines - 1),
          end_col = #lines > 0 and #lines[#lines] or 0,
        },
      },
    }
  else
    local ok, markdown_integration = pcall(require, "diagram/integrations/markdown")
    if not ok then return {} end
    return markdown_integration.query_buffer_diagrams(bufnr)
  end
end

local function get_diagram_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local diagrams = get_buffer_diagrams(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, diag in ipairs(diagrams) do
    local s_row = diag.range.start_row
    local e_row = diag.range.end_row
    for i = s_row, 0, -1 do
      if lines[i + 1] and lines[i + 1]:match("^%s*```") then
        s_row = i
        break
      end
    end
    for i = e_row, #lines - 1 do
      if lines[i + 1] and lines[i + 1]:match("^%s*```%s*$") then
        e_row = i
        break
      end
    end
    if row >= s_row and row <= e_row then
      return diag
    end
  end

  local ft = vim.bo[bufnr].filetype
  if (ft == "mermaid" or ft == "mmd") and #diagrams > 0 then
    return diagrams[1]
  end

  return nil
end

function M.clear_custom_images(bufnr)
  _G._diagram_custom_images = _G._diagram_custom_images or {}
  if bufnr then
    if _G._diagram_custom_images[bufnr] then
      for _, img in ipairs(_G._diagram_custom_images[bufnr]) do
        pcall(function() img:clear() end)
      end
      _G._diagram_custom_images[bufnr] = nil
    end
  else
    for _, imgs in pairs(_G._diagram_custom_images) do
      for _, img in ipairs(imgs) do
        pcall(function() img:clear() end)
      end
    end
    _G._diagram_custom_images = {}
  end
  pcall(function() require("diagram").clear() end)
  pcall(function() require("image").clear() end)
  _G._diagram_in_buffer_rendered = false
end

-- Render in-buffer sized to fill the entire terminal window width
function M.render_full_width()
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_get_current_win()

  if _G._diagram_in_buffer_rendered then
    M.clear_custom_images(bufnr)
    vim.notify("Diagram in-buffer cleared", vim.log.levels.INFO, { title = "Diagram" })
    return
  end

  local ok_image, image_nvim = pcall(require, "image")
  if not ok_image then
    vim.notify("image.nvim not available", vim.log.levels.ERROR, { title = "Diagram" })
    return
  end

  local diagrams = get_buffer_diagrams(bufnr)
  if #diagrams == 0 then
    vim.notify("No diagrams found in buffer", vim.log.levels.WARN, { title = "Diagram" })
    return
  end

  local renderer = require("diagram/renderers/mermaid")
  local options = get_mermaid_options()
  local win_width = vim.api.nvim_win_get_width(winnr)
  -- Fill virtually the full terminal window width (accounting for borders)
  local target_width = math.max(20, win_width - 2)

  M.clear_custom_images(bufnr)
  _G._diagram_custom_images[bufnr] = {}

  vim.notify("Rendering diagram to fill terminal width...", vim.log.levels.INFO, { title = "Diagram" })

  for _, diag in ipairs(diagrams) do
    local res = renderer.render(diag.source, options)
    if not res then goto continue end

    local function show_image()
      if vim.fn.filereadable(res.file_path) == 0 then return end
      if not vim.api.nvim_win_is_valid(winnr) or vim.api.nvim_win_get_buf(winnr) ~= bufnr then return end

      local cur_win_width = vim.api.nvim_win_get_width(winnr)
      local current_target = math.max(20, cur_win_width - 2)

      local img = image_nvim.from_file(res.file_path, {
        buffer = bufnr,
        window = winnr,
        with_virtual_padding = true,
        inline = true,
        x = 0,
        y = diag.range.start_row,
        width = current_target,
        render_offset_top = 1,
        ignore_global_max_size = true,
      })

      if img then
        table.insert(_G._diagram_custom_images[bufnr], img)
        img:render()
      end
    end

    if res.job_id then
      local timer = vim.loop.new_timer()
      if timer then
        timer:start(
          0,
          100,
          vim.schedule_wrap(function()
            local wait_result = vim.fn.jobwait({ res.job_id }, 0)
            if wait_result[1] ~= -1 then
              if timer:is_active() then timer:stop() end
              if not timer:is_closing() then
                timer:close()
                show_image()
              end
            end
          end)
        )
      end
    else
      show_image()
    end

    ::continue::
  end

  _G._diagram_in_buffer_rendered = true
  vim.notify("Diagram rendered at full terminal width", vim.log.levels.INFO, { title = "Diagram" })
end

-- Open dedicated hover tab with maximum diagram width
function M.show_diagram_tab()
  local bufnr = vim.api.nvim_get_current_buf()
  local diag = get_diagram_at_cursor(bufnr)
  if not diag then
    vim.notify("No diagram found at cursor", vim.log.levels.WARN, { title = "Diagram" })
    return
  end

  local ok_image, image_nvim = pcall(require, "image")
  if not ok_image then return end

  local renderer = require("diagram/renderers/mermaid")
  local options = get_mermaid_options()
  vim.notify("Loading diagram in dedicated tab...", vim.log.levels.INFO, { title = "Diagram" })

  local res = renderer.render(diag.source, options)
  if not res then return end

  local function open_tab()
    if vim.fn.filereadable(res.file_path) == 0 then
      vim.notify("Diagram file not found: " .. res.file_path, vim.log.levels.ERROR, { title = "Diagram" })
      return
    end

    vim.cmd("tabnew")
    local tab_buf = vim.api.nvim_get_current_buf()
    local tab_win = vim.api.nvim_get_current_win()

    vim.api.nvim_buf_set_name(tab_buf, "Mermaid Diagram Preview")
    vim.bo[tab_buf].buftype = "nofile"
    vim.bo[tab_buf].bufhidden = "wipe"
    vim.bo[tab_buf].swapfile = false

    vim.api.nvim_buf_set_lines(tab_buf, 0, -1, false, {
      "# MERMAID Diagram (Full Width)",
      "",
      "Press 'q' or <Esc> to close tab | Press 'o' to open in macOS Preview",
      "",
    })

    local tab_width = vim.api.nvim_win_get_width(tab_win)
    local target_width = math.max(20, tab_width - 2)

    local image = image_nvim.from_file(res.file_path, {
      buffer = tab_buf,
      window = tab_win,
      with_virtual_padding = true,
      inline = true,
      x = 0,
      y = 4,
      width = target_width,
      ignore_global_max_size = true,
    })

    if image then
      image:render()
    end

    local function close_tab()
      if image then image:clear() end
      vim.cmd("tabclose")
    end

    vim.keymap.set("n", "q", close_tab, { buffer = tab_buf, desc = "Close diagram tab" })
    vim.keymap.set("n", "<Esc>", close_tab, { buffer = tab_buf, desc = "Close diagram tab" })
    vim.keymap.set("n", "o", function()
      vim.ui.open(res.file_path)
    end, { buffer = tab_buf, desc = "Open image with system viewer" })
  end

  if res.job_id then
    local timer = vim.loop.new_timer()
    if timer then
      timer:start(
        0,
        100,
        vim.schedule_wrap(function()
          local wait_result = vim.fn.jobwait({ res.job_id }, 0)
          if wait_result[1] ~= -1 then
            if timer:is_active() then timer:stop() end
            if not timer:is_closing() then
              timer:close()
              open_tab()
            end
          end
        end)
      )
    end
  else
    open_tab()
  end
end

function M.open_system_viewer()
  local bufnr = vim.api.nvim_get_current_buf()
  local diag = get_diagram_at_cursor(bufnr)
  if not diag or not diag.source or vim.trim(diag.source) == "" then
    vim.notify("No Mermaid diagram found at cursor", vim.log.levels.WARN, { title = "Diagram" })
    return
  end

  local renderer = require("diagram/renderers/mermaid")
  local options = get_mermaid_options()

  vim.notify("Rendering high-res Mermaid diagram...", vim.log.levels.INFO, { title = "Diagram" })
  local result = renderer.render(diag.source, options)
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
end

M[1] = {
  "3rd/diagram.nvim",
  dependencies = {
    "3rd/image.nvim",
  },
  ft = { "markdown", "vimwiki", "mermaid", "mmd" },
  opts = function()
    return {
      renderer_options = {
        mermaid = get_mermaid_options(),
        plantuml = {
          charset = "utf-8",
        },
        d2 = {
          theme_id = 200,
        },
      },
      events = {
        render_buffer = {},
        clear_buffer = { "BufLeave", "BufWinLeave", "FocusLost" },
      },
    }
  end,
  config = function(_, opts)
    local integrations = require("diagram/integrations")
    local renderers = require("diagram/renderers")

    -- Support standalone .mermaid and .mmd files directly
    local mermaid_file_integration = {
      id = "mermaid_file",
      filetypes = { "mermaid", "mmd" },
      renderers = { renderers.mermaid },
      query_buffer_diagrams = function(bufnr)
        return get_buffer_diagrams(bufnr)
      end,
    }

    opts.integrations = {
      integrations.markdown,
      integrations.neorg,
      mermaid_file_integration,
    }

    require("diagram").setup(opts)

    -- Auto-clear custom images on buffer leave or focus lost
    vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", "FocusLost" }, {
      group = vim.api.nvim_create_augroup("DiagramCustomClear", { clear = true }),
      callback = function(ev)
        if _G._diagram_in_buffer_rendered then
          M.clear_custom_images(ev.buf)
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>md",
      function()
        M.show_diagram_tab()
      end,
      desc = "Show diagram in dedicated full-width tab (press 'q' to exit, 'o' to open)",
      ft = { "markdown", "vimwiki", "mermaid", "mmd" },
    },
    {
      "<leader>mo",
      function()
        M.open_system_viewer()
      end,
      desc = "Open diagram directly in macOS system viewer (Preview)",
      ft = { "markdown", "vimwiki", "mermaid", "mmd" },
    },
    {
      "<leader>mb",
      function()
        M.render_full_width()
      end,
      desc = "Toggle diagram in-buffer rendering (fills entire terminal page)",
      ft = { "markdown", "vimwiki", "mermaid", "mmd" },
    },
  },
}

return M
