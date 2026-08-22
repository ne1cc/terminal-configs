local M = {}

local function run_agy_buffer(prompt, title, context_file)
  -- 1. Create a markdown report buffer
  local report_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[report_buf].filetype = "markdown"
  vim.bo[report_buf].buftype = "nofile"
  local buf_title = "Antigravity: " .. (title or "Report")
  pcall(vim.api.nvim_buf_set_name, report_buf, buf_title)

  -- 2. Open vertical split
  vim.cmd("vsplit")
  local report_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(report_win, report_buf)

  -- Configure dynamic text wrapping for this window/buffer
  vim.wo[report_win].wrap = true
  vim.wo[report_win].linebreak = true
  vim.wo[report_win].breakindent = true
  vim.wo[report_win].breakindentopt = "shift:2,min:20"
  vim.wo[report_win].showbreak = "↳ "
  vim.wo[report_win].conceallevel = 2

  local initial_lines = {
    "# 🤖 " .. (title or "Antigravity Report"),
    "> Context: `" .. (context_file or "Buffer") .. "`",
    "",
    "⏳ *Analyzing and generating report with agyy...*",
    "",
  }
  vim.api.nvim_buf_set_lines(report_buf, 0, -1, false, initial_lines)

  -- 3. Run agyy asynchronously with live output accumulation
  local output_text = ""

  vim.system({
    "agy",
    "--dangerously-skip-permissions",
    "-p",
    prompt,
  }, {
    text = true,
    stdout = function(_, data)
      if data and data ~= "" then
        output_text = output_text .. data
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(report_buf) then
            local lines = {
              "# 🤖 " .. (title or "Antigravity Report"),
              "> Context: `" .. (context_file or "Buffer") .. "`",
              "",
            }
            for line in output_text:gmatch("([^\r\n]*)\r?\n?") do
              if line ~= "" then
                table.insert(lines, line)
              end
            end
            vim.api.nvim_buf_set_lines(report_buf, 0, -1, false, lines)
          end
        end)
      end
    end,
    stderr = function(_, err_data)
      -- Capture stderr if any warnings occur
    end,
  }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        vim.notify("Antigravity report complete! Press <leader>mp for full interactive preview or <leader>mv to open diagram.", vim.log.levels.INFO)
      else
        vim.notify("Antigravity error (exit code " .. obj.code .. "): " .. (obj.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

return {
  {
    "antigravity-integration",
    dir = vim.fn.stdpath("config"),
    name = "antigravity-integration",
    keys = {
      {
        "<leader>ar",
        function()
          local file_path = vim.api.nvim_buf_get_name(0)
          if file_path == "" then
            vim.notify("Please save the file first before running Antigravity report", vim.log.levels.WARN)
            return
          end

          local prompt = "Review this file: "
            .. file_path
            .. "\n\nPlease provide a clear, structured markdown report with:\n"
            .. "1. **Executive Summary** (Purpose and high-level role)\n"
            .. "2. **Key Components & Flow** (Provide clean ASCII/Unicode text flowcharts AND a concise Mermaid diagram with quoted labels to avoid syntax parsing issues)\n"
            .. "3. **Potential Issues, Bugs, or Edge Cases**\n"
            .. "4. **Concrete Improvement & Refactoring Suggestions**"

          run_agy_buffer(prompt, "Report: " .. vim.fn.fnamemodify(file_path, ":t"), file_path)
        end,
        desc = "Generate Antigravity Report for current file",
      },
      {
        "<leader>ae",
        function()
          local file_path = vim.api.nvim_buf_get_name(0)
          if file_path == "" then
            vim.notify("Please save the file first before running Antigravity query", vim.log.levels.WARN)
            return
          end

          vim.ui.input({ prompt = "Ask agyy about this file: " }, function(user_query)
            if not user_query or user_query == "" then
              return
            end

            local prompt = "File context: " .. file_path .. "\n\nUser Question: " .. user_query
            run_agy_buffer(prompt, user_query, file_path)
          end)
        end,
        desc = "Ask agyy a question about current file",
      },
      {
        "<leader>av",
        function()
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          local lines = vim.api.nvim_buf_get_text(0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3], {})
          local selected_text = table.concat(lines, "\n")
          local file_path = vim.api.nvim_buf_get_name(0)

          if selected_text == "" then
            vim.notify("No visual selection found", vim.log.levels.WARN)
            return
          end

          local prompt = "Context file: "
            .. file_path
            .. "\n\nExplain and review this selected code snippet:\n```\n"
            .. selected_text
            .. "\n```"

          run_agy_buffer(prompt, "Snippet Review", file_path)
        end,
        mode = "v",
        desc = "Explain / Review selected code snippet with agyy",
      },
    },
  },
}
