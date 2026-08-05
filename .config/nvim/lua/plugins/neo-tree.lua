return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 60,
      mappings = {
        ["<CR>"] = "open",
        ["o"] = "open_default",
      },
    },
    filesystem = {
      window = {
        mappings = {
          ["P"] = "toggle_preview",
          ["j"] = function(state)
            vim.cmd("normal! j")
            require("neo-tree.sources.filesystem.commands").open(state)
          end,
          ["k"] = function(state)
            vim.cmd("normal! k")
            require("neo-tree.sources.filesystem.commands").open(state)
          end,
        },
      },
      preview = {
        config = {
          width = 80,
          height = 40,
        },
      },
    },
  },
}
