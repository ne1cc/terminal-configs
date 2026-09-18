local function get_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    root = vim.fn.getcwd()
  end
  return root
end

-- Get relative path of a file with respect to project root
local function get_relative_path(file, root)
  if vim.startswith(file, root .. "/") then
    return file:sub(#root + 2)
  end
  return vim.fn.fnamemodify(file, ":t")
end

-- Executes an Antigravity prompt safely in the background, writing the LLM response
-- directly to doc_path and opening in One Markdown upon completion.
local function run_agyy_prompt_to_file(prompt_text, doc_path, task_desc)
  vim.notify("⏳ [Antigravity] " .. task_desc .. "...", vim.log.levels.INFO)

  -- Create parent directory
  local doc_dir = vim.fn.fnamemodify(doc_path, ":h")
  vim.fn.mkdir(doc_dir, "p")

  -- Write prompt to a temporary file to avoid command-line length and shell quote escaping issues
  local tmp_prompt = vim.fn.tempname() .. ".txt"
  local f = io.open(tmp_prompt, "w")
  if not f then
    vim.notify("❌ [Antigravity] Failed to create temp prompt file", vim.log.levels.ERROR)
    return
  end
  f:write(prompt_text)
  f:close()

  -- Wrap in subshell that captures agyy -p output into target file
  local runner_cmd = string.format(
    "PROMPT=$(cat %s); rm -f %s; agyy -p \"$PROMPT\" > %s 2>&1",
    vim.fn.shellescape(tmp_prompt),
    vim.fn.shellescape(tmp_prompt),
    vim.fn.shellescape(doc_path)
  )

  vim.fn.jobstart({ "sh", "-c", runner_cmd }, {
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
    border = "rounded",
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
          -- Explain Current File -> docs/explanations/<relative_path>.md
          ["<leader>ae"] = {
            function()
              local file = vim.fn.expand("%:p")
              if file == "" then
                vim.notify("No file in active buffer to explain", vim.log.levels.WARN)
                return
              end

              local root = get_project_root()
              local rel_path = get_relative_path(file, root)
              local doc_file = root .. "/docs/explanations/" .. rel_path .. ".md"
              local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              local file_content = table.concat(buf_lines, "\n")
              local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"

              local prompt = string.format([[
You are a senior principal systems architect. Provide a deep, comprehensive technical explanation of the source file `%s`.

Source File Content:
```%s
%s
```

Structure your explanation with:
1. **Executive Summary & System Role**: Core purpose, problem solved, and responsibilities.
2. **Architecture & Design Patterns**: Internal structure, state management, and algorithmic patterns.
3. **Public APIs & Interfaces**: Key classes, structs, methods, parameters, return types, and contracts.
4. **Data Flow & Dependencies**: External imports, input pipelines, transformation logic, and side effects.
5. **Notable Edge Cases & Constraints**: Error boundaries, concurrency, and operational trade-offs.

Format in clean GitHub-Flavored Markdown. Do NOT wrap the entire document in a single outer code block.
]], rel_path, filetype, file_content)

              run_agyy_prompt_to_file(prompt, doc_file, "Explaining " .. rel_path)
            end,
            desc = "Antigravity (agyy): Explain Current File (Background) -> docs/explanations/<relpath>.md & omd",
          },

          -- Review Current File -> docs/reviews/<relative_path>.md
          ["<leader>ar"] = {
            function()
              local file = vim.fn.expand("%:p")
              if file == "" then
                vim.notify("No file in active buffer to review", vim.log.levels.WARN)
                return
              end

              local root = get_project_root()
              local rel_path = get_relative_path(file, root)
              local doc_file = root .. "/docs/reviews/" .. rel_path .. ".md"
              local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              local file_content = table.concat(buf_lines, "\n")
              local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"

              local prompt = string.format([[
You are an adversarial senior software engineer and security reviewer. Conduct an in-depth code review of `%s`.

Source File Content:
```%s
%s
```

Structure your review with:
1. **Critical Flaws & Logical Bugs**: Edge cases, null/nil panics, race conditions, memory leaks.
2. **Security & Boundary Vulnerabilities**: Unsanitized inputs, authorization leaks, unsafe system calls.
3. **Performance Regressions & Inefficiencies**: Algorithmic complexity, unnecessary allocations, blocking I/O.
4. **Actionable Recommendations & Diffs**: Concrete fixes with minimal, surgical code snippets.

Format in clean GitHub-Flavored Markdown.
]], rel_path, filetype, file_content)

              run_agyy_prompt_to_file(prompt, doc_file, "Reviewing " .. rel_path)
            end,
            desc = "Antigravity (agyy): Review Current File (Background) -> docs/reviews/<relpath>.md & omd",
          },

          -- Summarize Whole Repository -> docs/explanations/INDEX.md
          ["<leader>as"] = {
            function()
              local root = get_project_root()
              local index_file = root .. "/docs/explanations/INDEX.md"
              vim.notify("⏳ [Antigravity] Starting background whole-repo summarization...", vim.log.levels.INFO)

              local cmd = string.format("cd %s && repo-summarize --open", vim.fn.shellescape(root))
              vim.fn.jobstart({ "sh", "-c", cmd }, {
                detach = true,
                on_exit = function(_, exit_code, _)
                  vim.schedule(function()
                    if exit_code == 0 and vim.fn.filereadable(index_file) == 1 then
                      vim.notify("✓ [Antigravity] Repo summarization complete! Opening in One Markdown...", vim.log.levels.INFO)
                    elseif exit_code ~= 0 then
                      vim.notify("❌ [Antigravity] Repo summarization failed (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                  end)
                end,
              })
            end,
            desc = "Antigravity (agyy): Summarize Whole Repo (Background) -> docs/explanations/INDEX.md & omd",
          },

          -- Headless OpenWiki Execution -> openwiki/ & quickstart.md
          ["<leader>ow"] = {
            function()
              local root = get_project_root()
              local has_openwiki = vim.fn.isdirectory(root .. "/openwiki") == 1
              local subcmd = has_openwiki and "--update" or "--init"
              local target_doc = root .. "/openwiki/quickstart.md"

              vim.notify(
                string.format("⏳ [OpenWiki] Running headless %s in background for %s...", subcmd, vim.fn.fnamemodify(root, ":t")),
                vim.log.levels.INFO
              )

              local err_lines = {}
              local cmd = string.format("cd %s && openwiki code %s --print", vim.fn.shellescape(root), subcmd)
              vim.fn.jobstart({ "sh", "-c", cmd }, {
                detach = true,
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = function(_, data, _)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then table.insert(err_lines, line) end
                    end
                  end
                end,
                on_stderr = function(_, data, _)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then table.insert(err_lines, line) end
                    end
                  end
                end,
                on_exit = function(_, exit_code, _)
                  vim.schedule(function()
                    if exit_code == 0 then
                      vim.notify("✓ [OpenWiki] Documentation generation complete!", vim.log.levels.INFO)
                      if vim.fn.filereadable(target_doc) == 1 then
                        if vim.fn.executable("omd") == 1 then
                          vim.fn.jobstart({ "omd", target_doc }, { detach = true })
                        else
                          vim.cmd("edit " .. vim.fn.fnameescape(target_doc))
                        end
                      end
                    else
                      local err_msg = table.concat(err_lines, " "):gsub("^%s*(.-)%s*$", "%1")
                      if err_msg == "" then
                        err_msg = "exit code " .. exit_code
                      end
                      vim.notify("❌ [OpenWiki] " .. err_msg, vim.log.levels.ERROR)
                    end
                  end)
                end,
              })
            end,
            desc = "OpenWiki: Run Headless Update/Init (Background) -> openwiki/ & omd",
          },

          -- Interactive Terminal Chat
          ["<leader>at"] = {
            function()
              run_agyy_interactive("Chat with user")
            end,
            desc = "Antigravity (agyy): Interactive Terminal",
          },
        },

        v = {
          -- Visual Selection Mode -> Saved to docs/snippets/ with rich metadata
          ["<leader>ae"] = {
            function()
              local start_pos = vim.fn.getpos("'<")
              local end_pos = vim.fn.getpos("'>")
              local start_line = start_pos[2]
              local end_line = end_pos[2]
              local file = vim.fn.expand("%:p")
              local root = get_project_root()
              local rel_path = (file ~= "") and get_relative_path(file, root) or "untitled"
              local filename = vim.fn.fnamemodify(rel_path, ":t:r")
              local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"

              -- Extract exact buffer lines
              local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
              local snippet_text = table.concat(lines, "\n")

              -- Isolated folder for snippets and buffer reads
              local snippets_dir = root .. "/docs/snippets"
              local timestamp = os.date("%Y%m%d_%H%M%S")
              local doc_file = string.format("%s/%s_L%d-L%d_%s.md", snippets_dir, filename, start_line, end_line, timestamp)

              local prompt = string.format([[
You are a senior systems engineer. Provide a precise, line-by-line and architectural breakdown of the following code snippet from `%s` (lines %d to %d).

Code Snippet:
```%s
%s
```

Metadata:
- File: `%s`
- Lines: %d to %d
- Timestamp: %s

Explain:
1. **Core Intent**: What do these specific lines accomplish?
2. **Mechanism & Logic Walkthrough**: Step-by-step breakdown of variables, flow control, and functions called.
3. **Hidden Invariants & Edge Cases**: Potential pitfalls, assumptions about caller context, and performance impact.

Format in clean GitHub-Flavored Markdown.
]], rel_path, start_line, end_line, filetype, snippet_text, rel_path, start_line, end_line, timestamp)

              run_agyy_prompt_to_file(prompt, doc_file, string.format("Explaining %s [L%d-L%d]", rel_path, start_line, end_line))
            end,
            desc = "Antigravity (agyy): Explain Selection (Background) -> docs/snippets/*.md & omd",
          },
        },
      },
    },
  },
}
