return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 60,
      mappings = {
        ["<CR>"] = "open",
        ["o"] = "open",
        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
      },
    },
    filesystem = {
      window = {
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        },
      },
    },
  },
}
