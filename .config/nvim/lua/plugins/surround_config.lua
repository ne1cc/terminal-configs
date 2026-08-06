return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  opts = {
    surrounds = {
      ["~"] = {
        add = { "~~", "~~" },
        find = "~~.-~~",
        delete = "^(~~)().*(~~)()$",
      },
    },
  },
  config = function(_, opts)
    require("nvim-surround").setup(opts)
  end,
}
