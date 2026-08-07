return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 40,
      position = "left",
      mappings = {
        ["<CR>"] = "open",
        ["o"] = "open",
        ["P"] = "toggle_preview",
      },
    },
  },
}
