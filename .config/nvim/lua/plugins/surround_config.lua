return {
  "kylechui/nvim-surround",
  opts = {
    surrounds = {
      ["~"] = {
        add = { "~~", "~~" },
        find = "~~.-~~",
        delete = "^(~~)().*(~~)()$",
      },
    },
  },
}
