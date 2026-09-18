local function get_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    root = vim.fn.getcwd()
  end
  return root
end

-- Runs a headless background task without popping up any terminal window.
-- Notifies the user on start and on completion, then opens the result in One Markdown.
local function run_headless_task(cmd_str, doc_path, task_desc)
  vim.notify("⏳ [Antigravity] " .. task_desc .. "...", vim.log.levels.INFO)

  vim.fn.jobstart({ "sh", "-c", cmd_str }, {
    detach = true,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 and doc_path and vim.fn.filereadable(doc_path) == 1 then
          vim.notify("✓ [Antigravity] " .. task_desc .. " complete! Opening in One Markdown...", vim.log.levels.INFO)
          vim.fn.jobstart({ "omd", doc_path }, { detach = true })
        elseif exit_code ~= 0 then
          vim.notify("❌ [Antigravity] " .. task_desc .. " failed (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

local function run_agyy_interactive(prompt)
  -- Create floating buffer/window natively only when explicit interactive chat is requested
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "curved",
    title = " Antigravity (agyy) ",
    title_pos = "center",
  })

  -- Keybindings inside this window to close or hide
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close_win, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, silent = true })
  vim.keymap.set("t", "<C-q>", "<C-\\><C-n><cmd>close<cr>", { buffer = buf, silent = true })

  -- Launch terminal job
  local cmd = string.format("agyy -i %s", vim.fn.shellescape(prompt))
  vim.fn.termopen(cmd)
  vim.cmd("startinsert")
end

return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<leader>ae"] = {
            function()
              local file = vim.fn.expand("%:p")
              if file == "" then
                vim.notify("No file in active buffer to explain", vim.log.levels.WARN)
                return
              end

              local filename = vim.fn.expand("%:t")
              local root = get_project_root()
              local explanations_dir = root .. "/docs/explanations"
              vim.fn.mkdir(explanations_dir, "p")
              local doc_file = explanations_dir .. "/" .. filename .. ".md"

              local prompt = string.format(
                "Explain the architecture, design, and key logic of `%s`. Write the complete explanation in clean markdown directly into `%s`.",
                file,
                doc_file
              )
              local cmd = string.format("agyy -p %s", vim.fn.shellescape(prompt))
              run_headless_task(cmd, doc_file, "Explaining " .. filename)
            end,
            desc = "Antigravity (agyy): Explain Current File (Background) -> docs/explanations/*.md & omd",
          },
          ["<leader>ar"] = {
            function()
              local file = vim.fn.expand("%:p")
              if file == "" then
                vim.notify("No file in active buffer to review", vim.log.levels.WARN)
                return
              end

              local filename = vim.fn.expand("%:t")
              local root = get_project_root()
              local reviews_dir = root .. "/docs/reviews"
              vim.fn.mkdir(reviews_dir, "p")
              local doc_file = reviews_dir .. "/" .. filename .. ".md"

              local prompt = string.format(
                "Review `%s` for bugs, edge cases, and performance regressions. Write the findings in clean markdown directly into `%s`.",
                file,
                doc_file
              )
              local cmd = string.format("agyy -p %s", vim.fn.shellescape(prompt))
              run_headless_task(cmd, doc_file, "Reviewing " .. filename)
            end,
            desc = "Antigravity (agyy): Review Current File (Background) -> docs/reviews/*.md & omd",
          },
          ["<leader>as"] = {
            function()
              local root = get_project_root()
              local index_file = root .. "/docs/explanations/INDEX.md"
              local cmd = string.format("cd %s && repo-summarize --open", vim.fn.shellescape(root))
              run_headless_task(cmd, index_file, "Summarizing repository files")
            end,
            desc = "Antigravity (agyy): Summarize Whole Repo (Background) -> docs/explanations/INDEX.md & omd",
          },
          ["<leader>at"] = {
            function()
              run_agyy_interactive("Chat with user")
            end,
            desc = "Antigravity (agyy): Interactive Terminal",
          },
        },
        v = {
          ["<leader>ae"] = {
            function()
              local start_line = vim.fn.line("'<")
              local end_line = vim.fn.line("'>")
              local file = vim.fn.expand("%:p")
              local filename = vim.fn.expand("%:t")
              local root = get_project_root()
              local explanations_dir = root .. "/docs/explanations"
              vim.fn.mkdir(explanations_dir, "p")
              local doc_file = explanations_dir .. "/" .. filename .. "_lines_" .. start_line .. "-" .. end_line .. ".md"

              local prompt = string.format(
                "Explain lines %d-%d in `%s`. Write the explanation in clean markdown directly into `%s`.",
                start_line,
                end_line,
                file,
                doc_file
              )
              local cmd = string.format("agyy -p %s", vim.fn.shellescape(prompt))
              run_headless_task(cmd, doc_file, "Explaining " .. filename .. " (lines " .. start_line .. "-" .. end_line .. ")")
            end,
            desc = "Antigravity (agyy): Explain Selection (Background) -> docs/explanations/*.md & omd",
          },
        },
      },
    },
  },
}
