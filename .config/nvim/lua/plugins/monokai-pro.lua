return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      filter = "pro", -- classic, octagon, machine, risti, spectrum, pro
      terminal_colors = true,
      devicons = true,
      background_clear = {
        "neo-tree",
        "telescope",
        "toggleterm",
        "which-key",
        "notify",
      },
    },
  }
}
