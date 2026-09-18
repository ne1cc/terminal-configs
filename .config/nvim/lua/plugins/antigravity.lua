local function get_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    root = vim.fn.getcwd()
  end
  return root
end

local function run_agyy_and_view(prompt, doc_path)
  -- Create floating buffer/window natively
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
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code, _)
      if doc_path and vim.fn.filereadable(doc_path) == 1 then
        vim.notify("Explanation saved to " .. doc_path .. ". Opening in One Markdown...", vim.log.levels.INFO)
        vim.fn.jobstart({ "omd", doc_path }, { detach = true })
      end
    end,
  })
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
              run_agyy_and_view(prompt, doc_file)
            end,
            desc = "Antigravity (agyy): Explain Current File -> docs/explanations/*.md & open omd",
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
              run_agyy_and_view(prompt, doc_file)
            end,
            desc = "Antigravity (agyy): Review Current File -> docs/reviews/*.md & open omd",
          },
          ["<leader>at"] = {
            function()
              run_agyy_and_view("Chat with user", nil)
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
              run_agyy_and_view(prompt, doc_file)
            end,
            desc = "Antigravity (agyy): Explain Selection -> docs/explanations/*.md & open omd",
          },
        },
      },
    },
  },
}
