return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown" },
  opts = {
    default = {
      dir_path = "assets/images",
      extension = "png",
      file_name = "%Y-%m-%d-%H-%M-%S",
      use_absolute_path = false,
      relative_to_current_file = true,
      template = "![$CURSOR]($FILE_PATH)",
    },
  },
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard", ft = "markdown" },
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard", ft = "markdown" },
  },
}

