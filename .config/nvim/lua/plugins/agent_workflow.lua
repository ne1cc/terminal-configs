return {
  -- 1. DIFFVIEW: Side-by-side git diffs for reviewing agent overhauls
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    config = true,
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
