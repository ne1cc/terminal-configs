-- Helper to extract and sort target file paths from neo-tree selection or cursor
local function get_nodes_to_open(state, selected_nodes)
  local nodes = {}
  -- 1. Check tagged nodes (set via `v` or `<Tab>`)
  if state.selected and vim.tbl_count(state.selected) > 0 then
    for id in pairs(state.selected) do
      local node = state.tree:get_node(id)
      if node and node.type == "file" then
        table.insert(nodes, node.path)
      end
    end
  -- 2. Check visual selection nodes (e.g. range selected in `V` mode)
  elseif selected_nodes and #selected_nodes > 0 then
    for _, node in ipairs(selected_nodes) do
      if node and node.type == "file" then
        table.insert(nodes, node.path)
      end
    end
  -- 3. Fallback: single node under cursor
  else
    local node = state.tree:get_node()
    if node and node.type == "file" then
      table.insert(nodes, node.path)
    end
  end

  local unique_paths = {}
  local seen = {}
  for _, path in ipairs(nodes) do
    if not seen[path] then
      seen[path] = true
      table.insert(unique_paths, path)
    end
  end

  table.sort(unique_paths)
  return unique_paths
end

local function open_all_selected_nodes(state, selected_nodes)
  local paths = get_nodes_to_open(state, selected_nodes)
  if #paths == 0 then
    vim.notify("Neo-tree: No files selected to open", vim.log.levels.WARN)
    return
  end

  -- 1. Load all chosen paths into Neovim buffers
  for _, path in ipairs(paths) do
    vim.cmd("badd " .. vim.fn.fnameescape(path))
  end

  -- 2. Open first file in the editor window (safely avoids replacing neo-tree)
  local nt_utils = require("neo-tree.utils")
  nt_utils.open_file(state, paths[1], "edit")

  -- 3. Clear tagged selections if set
  if state.selected and vim.tbl_count(state.selected) > 0 then
    state.selected = {}
    require("neo-tree.ui.renderer").redraw(state)
  end

  vim.notify(string.format("Loaded %d file(s) into buffers", #paths), vim.log.levels.INFO)
end

local function quickfix_selected_nodes(state, selected_nodes)
  local paths = get_nodes_to_open(state, selected_nodes)
  if #paths == 0 then
    vim.notify("Neo-tree: No files selected for quickfix", vim.log.levels.WARN)
    return
  end

  local qf_items = {}
  for _, path in ipairs(paths) do
    table.insert(qf_items, { filename = path, lnum = 1, col = 1 })
  end
  vim.fn.setqflist(qf_items, "r")
  vim.cmd("copen")

  if state.selected and vim.tbl_count(state.selected) > 0 then
    state.selected = {}
    require("neo-tree.ui.renderer").redraw(state)
  end
end

return {
  -- 1. DIFFVIEW: Side-by-side git diffs for reviewing agent overhauls
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Review Agent Diff" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      { "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle File Tree" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview Current File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
      view = {
        default = {
          layout = "diff2_horizontal", -- Side-by-side split review
        },
      },
      keymaps = {
        view = {
          -- Quick keyboard review motions
          ["]q"] = "<cmd>DiffviewNextClose<cr>",
          ["[q"] = "<cmd>DiffviewPrevClose<cr>",
        },
        file_panel = {
          ["s"] = false, -- Disable default stage
          ["<space>"] = "toggle_stage_entry", -- Space to stage/unstage files
          ["c"] = "<cmd>Neogit commit<cr>",
        },
      },
    },
  },

  -- NEOGIT: Magit clone for Neovim with direct Diffview integration
  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit Status" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
  },

  -- 2. TELESCOPE: Advanced file browsing and live-grep with built-in previews
  -- (AstroNvim includes Telescope by default, but this config adds the File Browser extension)
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  -- 3. LAZYGIT: Toggle LazyGit in a beautiful floating terminal inside Neovim
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- Optional dependencies
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- Setting up the keymap to match AstroNvim's style
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- 4. UNDOTREE: A time machine for your code (Crucial for agent slip-ups)
  -- If the agent overwrites a file completely, this lets you browse a visual tree
  -- of your undo history, even across file saves.
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Toggle UndoTree" },
    },
  },

  -- 5. NEO-TREE: Positioning and preview configuration
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- keep neo-tree as a sidebar so preview windows can open safely
      close_if_last_window = false,
      window = {
        position = "left",
        width = 40,
        mapping_options = { noremap = true, nowait = true },
        mappings = {
          ["<cr>"] = "open",
          ["P"] = {
            "toggle_preview",
            config = { use_float = true, use_snacks_image = true, use_image_nvim = true },
          },
          ["l"] = "focus_preview",
          ["v"] = "select",
          ["O"] = "open_all_selected",
          ["<C-q>"] = "quickfix_selected",
        },
      },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true, leave_dirs_open = false },
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["P"] = {
              "toggle_preview",
              config = { use_float = true, use_snacks_image = true, use_image_nvim = true },
            },
            ["l"] = "focus_preview",
            ["E"] = "expand_all_nodes",
            ["M"] = "open_mupdf",
            ["v"] = "select",
            ["O"] = "open_all_selected",
            ["<C-q>"] = "quickfix_selected",
          },
        },
      },
      commands = {
        open_mupdf = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          if filepath and node.type == "file" then
            vim.fn.jobstart({ "mupdf", filepath }, { detach = true })
          end
        end,
        open_all_selected = function(state)
          open_all_selected_nodes(state)
        end,
        open_all_selected_visual = function(state, selected_nodes)
          open_all_selected_nodes(state, selected_nodes)
        end,
        quickfix_selected = function(state)
          quickfix_selected_nodes(state)
        end,
        quickfix_selected_visual = function(state, selected_nodes)
          quickfix_selected_nodes(state, selected_nodes)
        end,
      },
    },
    -- ensure setup is run with our opts and add debounced autocmds to auto-open previews on movement
    config = function(_, opts)
      require("neo-tree").setup(opts)
      local group = vim.api.nvim_create_augroup("NeoTreeAutoPreview", { clear = true })
      -- debounce so rapid keypresses (arrow keys / hjkl) don't spam preview actions
      local last_preview = 0
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        callback = function()
          if vim.bo.filetype == "neo-tree" then
            local now = vim.loop.hrtime()
            -- 100ms debounce (hrtime returns nanoseconds)
            if now - last_preview < 100000000 then
              return
            end
            last_preview = now
            -- Safely try to focus the preview (non-blocking)
            pcall(function()
              vim.cmd("Neotree action focus_preview")
            end)
          end
        end,
      })
    end,
  },
}
