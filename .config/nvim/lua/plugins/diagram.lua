local function get_chrome_executable()
  if vim.env.PUPPETEER_EXECUTABLE_PATH and vim.fn.filereadable(vim.env.PUPPETEER_EXECUTABLE_PATH) == 1 then
    return vim.env.PUPPETEER_EXECUTABLE_PATH
  end
  local candidates = {
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    "/usr/bin/google-chrome",
    "/usr/bin/google-chrome-stable",
    "/usr/bin/chromium",
    "/usr/bin/chromium-browser",
    "/snap/bin/chromium",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      vim.env.PUPPETEER_EXECUTABLE_PATH = path
      return path
    end
  end
  if vim.fn.executable("google-chrome") == 1 then
    local p = vim.fn.exepath("google-chrome")
    vim.env.PUPPETEER_EXECUTABLE_PATH = p
    return p
  elseif vim.fn.executable("chromium") == 1 then
    local p = vim.fn.exepath("chromium")
    vim.env.PUPPETEER_EXECUTABLE_PATH = p
    return p
  end
  return nil
end

get_chrome_executable()

local function open_diagram_in_system_viewer()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local source = nil

  if ft == "mermaid" or ft == "mmd" then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    source = table.concat(lines, "\n")
  else
    local markdown_integration = require("diagram/integrations/markdown")
    local diagrams = markdown_integration.query_buffer_diagrams(bufnr)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1

    for _, diag in ipairs(diagrams) do
      -- Look backwards from start_row to find the opening fence
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
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
        source = diag.source
        break
      end
    end
  end

  if not source or vim.trim(source) == "" then
    vim.notify("No Mermaid diagram found at cursor", vim.log.levels.WARN, { title = "Diagram" })
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
end

return {
  {
    "3rd/diagram.nvim",
    dependencies = {
      "3rd/image.nvim",
    },
    ft = { "markdown", "vimwiki", "mermaid", "mmd" },
    opts = function()
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
        renderer_options = {
          mermaid = {
            background = "#1a1b26", -- Opaque TokyoNight dark to match terminal and prevent text bleed-through
            theme = "dark",
            scale = 3.0,            -- Retina 300+ DPI high-resolution output
            width = 1800,           -- Wide viewport preventing label cramping/truncation
            cli_args = cli_args,
          },
          plantuml = {
            charset = "utf-8",
          },
          d2 = {
            theme_id = 200,
          },
        },
        events = {
          -- Do not auto-render in-buffer on open to prevent collisions with code text;
          -- use <leader>md (dedicated tab preview) or <leader>mb (toggle in-buffer)
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
          bufnr = bufnr or vim.api.nvim_get_current_buf()
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
        end,
      }

      opts.integrations = {
        integrations.markdown,
        integrations.neorg,
        mermaid_file_integration,
      }

      require("diagram").setup(opts)
    end,
    keys = {
      {
        "<leader>md",
        function()
          require("diagram").show_diagram_hover()
        end,
        desc = "Show diagram in dedicated tab (press 'q' to exit, 'o' to open)",
        ft = { "markdown", "vimwiki", "mermaid", "mmd" },
      },
      {
        "<leader>mo",
        open_diagram_in_system_viewer,
        desc = "Open diagram directly in macOS system viewer (Preview)",
        ft = { "markdown", "vimwiki", "mermaid", "mmd" },
      },
      {
        "<leader>mb",
        function()
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
        end,
        desc = "Toggle diagram in-buffer rendering",
        ft = { "markdown", "vimwiki", "mermaid", "mmd" },
      },
    },
  },
}
