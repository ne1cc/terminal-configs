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

-- Shared output spec for explain prompts (file + selection) so they stay in sync.
local EXPLAIN_FORMAT = [[
Write a walkthrough so the reader can walk away knowing what the code does and where to go next. Use exactly these sections, in order, as GitHub-Flavored Markdown:

## TL;DR
2-3 plain sentences: what this code does and why it exists.

## Big Picture
One Mermaid `flowchart TD` showing how the main pieces connect (functions, modules, or the control flow of the lines).

## Key Terms
A table with columns: Name | Kind | What it does | Used by. Cover only the functions, variables, types and config values that matter.

## Walkthrough
Go in order, block by block. Group consecutive lines that do one job under a heading that includes the line range, e.g. `### L12-18: Load config`. Under each, write 1-3 short sentences of plain prose on what it does and why. Give a single line its own note only if it is non-obvious (a regex, a clever expression, a side effect). Where there is branching, async work, or a request/response flow, add a Mermaid `sequenceDiagram` or `stateDiagram-v2` in that block.

## Inputs, Outputs & Side Effects
A table with columns: Kind | Item | Notes. Kinds: Input, Output, Side effect (files, network, globals), Error behavior.

## Gotchas
A table with columns: Situation | What happens | Why it matters. Include only real edge cases. Omit this section if there are none.

## Where To Go Next
An ordered reading path: 2-4 specific files, functions or line ranges to read next and why. Then 2-3 pointers in the form "To change X, start at Y".

Style rules:
- Plain, direct prose. Explain why, not just what. Do not restate the code. Define any jargon on first use.
- Mermaid must be valid: wrap every node label in double quotes, avoid parentheses and special characters outside quotes, and keep each diagram to about 12 nodes or fewer.
- Keep tables compact. Skip a section rather than pad it.
- Do NOT wrap the whole document in a single outer code block.
]]

-- Prefix each line with its 1-based number (offset-aware) so the model cites accurate ranges.
local function number_lines(lines, first)
  local out = {}
  for i, l in ipairs(lines) do
    out[i] = string.format("%d: %s", first + i - 1, l)
  end
  return table.concat(out, "\n")
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
              local file_content = number_lines(buf_lines, 1)
              local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"

              -- Extract import/include/require/use lines for cross-referencing
              local imports = {}
              for _, line in ipairs(buf_lines) do
                local s = line:match("^%s*(.-)%s*$")
                if s:match("^#include") or s:match("^import ") or
                   s:match("^from .+ import") or s:match("^require") or
                   s:match("^use ") then
                  table.insert(imports, s)
                end
              end

              -- Build Related Files list (link if doc exists, note if not)
              local related_lines = {}
              for _, imp in ipairs(imports) do
                local dep = imp:match('["\']([^"\']+)["\']') or imp:match("<([^>]+)>") or imp
                local dep_base = dep:match("([^/]+)$") or dep
                if vim.fn.filereadable(root .. "/docs/explanations/" .. dep .. ".md") == 1 then
                  table.insert(related_lines, "- [" .. dep .. "](" .. dep .. ".md) ✓")
                else
                  table.insert(related_lines, "- `" .. dep_base .. "` *(not yet explained)*")
                end
              end

              -- Load or reuse cached project overview to give AI repo context without wasting tokens
              local project_overview = ""
              local overview_candidates = { "AGENTS.md", "CLAUDE.md", "README.md" }
              for _, candidate in ipairs(overview_candidates) do
                local candidate_path = root .. "/" .. candidate
                if vim.fn.filereadable(candidate_path) == 1 then
                  local lines = vim.fn.readfile(candidate_path, "", 40) -- Read only the top 40 lines (overview & architecture)
                  project_overview = table.concat(lines, "\n")
                  break
                end
              end

              local prompt = string.format([[
You are a senior principal systems architect. Provide a deep, comprehensive technical explanation of the source file `%s`.

Repository Context (Target Repo: %s):
```markdown
%s
```

Source File Content (each line is prefixed with its line number; do not include the prefixes in quotes of code):
```%s
%s
```

Detected imports/dependencies:
%s

For this whole file, the Big Picture and Key Terms should show its public surface, internal structure, and how it relates to each detected dependency above (what it takes from each and how data flows). In Where To Go Next, prefer the detected dependencies and the files that likely call this one.

%s
]], rel_path, vim.fn.fnamemodify(root, ":t"), project_overview ~= "" and project_overview or "(Project root: " .. root .. ")", filetype, file_content,
                #imports > 0 and table.concat(imports, "\n") or "(none detected)", EXPLAIN_FORMAT)

              -- Use shared helper; after it finishes, append Related Files section
              local doc_dir = vim.fn.fnamemodify(doc_file, ":h")
              vim.fn.mkdir(doc_dir, "p")

              local tmp_prompt = vim.fn.tempname() .. ".txt"
              local pf = io.open(tmp_prompt, "w")
              if not pf then
                vim.notify("❌ [Antigravity] Failed to create temp prompt file", vim.log.levels.ERROR)
                return
              end
              pf:write(prompt)
              pf:close()

              local runner_cmd = string.format(
                "PROMPT=$(cat %s); rm -f %s; agyy -p \"$PROMPT\" > %s 2>&1",
                vim.fn.shellescape(tmp_prompt),
                vim.fn.shellescape(tmp_prompt),
                vim.fn.shellescape(doc_file)
              )

              vim.notify("⏳ [Antigravity] Explaining " .. rel_path .. " in background...", vim.log.levels.INFO)
              local err_output = {}
              vim.fn.jobstart({ "sh", "-c", runner_cmd }, {
                detach = true,
                stdout_buffered = true,
                stderr_buffered = true,
                on_stderr = function(_, data, _)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then table.insert(err_output, line) end
                    end
                  end
                end,
                on_exit = function(_, exit_code, _)
                  vim.schedule(function()
                    if exit_code == 0 and vim.fn.filereadable(doc_file) == 1 then
                      -- Append Related Files section without a second AI call
                      if #related_lines > 0 then
                        local af = io.open(doc_file, "a")
                        if af then
                          af:write("\n\n---\n\n## Related Files\n\n")
                          af:write(table.concat(related_lines, "\n"))
                          af:write("\n")
                          af:close()
                        end
                      end
                      vim.notify("✓ [Antigravity] Explanation saved → " .. rel_path .. ".md", vim.log.levels.INFO)
                      if vim.fn.executable("omd") == 1 then
                        vim.fn.jobstart({ "omd", doc_file }, { detach = true })
                      else
                        vim.cmd("edit " .. vim.fn.fnameescape(doc_file))
                      end
                    else
                      local detail = #err_output > 0 and table.concat(err_output, " ") or ("exit code " .. exit_code)
                      vim.notify("❌ [Antigravity] Explanation failed for " .. rel_path .. ": " .. detail, vim.log.levels.ERROR)
                    end
                  end)
                end,
              })
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

          -- Summarize Whole Repository -> docs/architecture/INDEX.md
          ["<leader>as"] = {
            function()
              local root = get_project_root()
              local index_file = root .. "/docs/architecture/INDEX.md"
              vim.notify("⏳ [Antigravity] Starting background whole-repo summarization → docs/architecture/...", vim.log.levels.INFO)

              local cmd = string.format("cd %s && repo-summarize --open", vim.fn.shellescape(root))
              vim.fn.jobstart({ "sh", "-c", cmd }, {
                detach = true,
                on_exit = function(_, exit_code, _)
                  vim.schedule(function()
                    if exit_code == 0 and vim.fn.filereadable(index_file) == 1 then
                      vim.notify("✓ [Antigravity] Repo summarization complete! Opening docs/architecture/INDEX.md...", vim.log.levels.INFO)
                    elseif exit_code ~= 0 then
                      vim.notify("❌ [Antigravity] Repo summarization failed (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                  end)
                end,
              })
            end,
            desc = "Antigravity (agyy): Summarize Whole Repo (Background) -> docs/architecture/INDEX.md & omd",
          },


          -- Check Repo Summarization Progress
          ["<leader>aS"] = {
            function()
              local root = get_project_root()
              local progress_file = root .. "/docs/architecture/.progress.json"
              if vim.fn.filereadable(progress_file) == 1 then
                local lines = vim.fn.readfile(progress_file)
                local json_str = table.concat(lines, "\n")
                local ok, data = pcall(vim.json.decode, json_str)
                if ok and data then
                  local msg = string.format(
                    "📊 [Antigravity Progress] %d / %d files (%d%%)\nStatus: %s\nCurrent: %s\nUpdated: %s",
                    data.processed or 0,
                    data.total_files or 0,
                    data.percent or 0,
                    data.status or "unknown",
                    data.current_file or "none",
                    data.updated_at or ""
                  )
                  vim.notify(msg, vim.log.levels.INFO, { title = "Repo Summarizer" })
                  return
                end
              end

              -- Fallback: count markdown files in docs/architecture
              local existing = vim.fn.globpath(root .. "/docs/architecture", "**/*.md", false, true)
              local count = #existing
              vim.notify(string.format("ℹ️ [Antigravity] No active progress file. Found %d generated architecture doc(s).", count), vim.log.levels.INFO)
            end,
            desc = "Antigravity (agyy): Check Repo Summarization Progress",
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

          -- Explanation Graph Visualization -> docs/explanations/GRAPH.html
          ["<leader>av"] = {
            function()
              local root = get_project_root()
              local out = root .. "/docs/explanations/GRAPH.html"
              vim.notify("⏳ [Antigravity] Building explanation graph (zero-cost)...", vim.log.levels.INFO)
              vim.fn.jobstart({ "sh", "-c", "explain-viz --open " .. vim.fn.shellescape(root) }, {
                detach = true,
                on_exit = function(_, exit_code, _)
                  vim.schedule(function()
                    if exit_code == 0 then
                      vim.notify("✓ [Antigravity] Graph → " .. out, vim.log.levels.INFO)
                    else
                      vim.notify("❌ [Antigravity] explain-viz failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                  end)
                end,
              })
            end,
            desc = "Antigravity: Visualize docs/explanations/ as D3 graph -> GRAPH.html (zero AI cost)",
          },

          -- Open HTML in browser (current buffer if .html, else GRAPH.html)
          ["<leader>oh"] = {
            function()
              local file = vim.fn.expand("%:p")
              local target

              if file:match("%.html$") and vim.fn.filereadable(file) == 1 then
                target = file
              else
                -- Fall back to the explanation graph
                local root = get_project_root()
                local graph = root .. "/docs/explanations/GRAPH.html"
                if vim.fn.filereadable(graph) == 1 then
                  target = graph
                else
                  vim.notify("No .html file in buffer and no GRAPH.html found. Run <Leader>av first.", vim.log.levels.WARN)
                  return
                end
              end

              local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
              vim.fn.jobstart({ opener, target }, { detach = true })
              vim.notify("🌐 Opening in browser: " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
            end,
            desc = "Open current .html buffer (or GRAPH.html) in system browser",
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
              local snippet_text = number_lines(lines, start_line)

              -- Isolated folder for snippets and buffer reads
              local snippets_dir = root .. "/docs/snippets"
              local timestamp = os.date("%Y%m%d_%H%M%S")
              local doc_file = string.format("%s/%s_L%d-L%d_%s.md", snippets_dir, filename, start_line, end_line, timestamp)

              local prompt = string.format([[
You are a senior systems engineer and patient teacher. Explain the following code snippet from `%s` (lines %d to %d).

Code Snippet (each line is prefixed with its real line number in the file; do not include the prefixes in quotes of code):
```%s
%s
```

Metadata:
- File: `%s`
- Lines: %d to %d
- Timestamp: %s

For this snippet, the Big Picture should show the control flow of these lines. Assume the reader has not seen the rest of the file: note what the snippet expects from its caller or surrounding code. In Where To Go Next, point to the surrounding code (callers, callees, definitions) to read next.

%s
]], rel_path, start_line, end_line, filetype, snippet_text, rel_path, start_line, end_line, timestamp, EXPLAIN_FORMAT)

              run_agyy_prompt_to_file(prompt, doc_file, string.format("Explaining %s [L%d-L%d]", rel_path, start_line, end_line))
            end,
            desc = "Antigravity (agyy): Explain Selection (Background) -> docs/snippets/*.md & omd",
          },
        },
      },
    },
  },
}
