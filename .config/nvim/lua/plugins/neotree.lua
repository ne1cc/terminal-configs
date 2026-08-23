return {
  -- Disable snacks.explorer so it does not open simultaneously with Neo-tree
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false, replace_netrw = false },
      picker = {
        sources = {
          explorer = { enabled = false },
        },
      },
    },
  },

  -- Neo-tree as the dedicated sidebar file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    opts = {
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
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
      window = {
        mappings = {
          ["E"] = "expand_all",
          ["M"] = "open_mupdf",
        },
      },
    },
  },
}
