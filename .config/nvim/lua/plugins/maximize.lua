return {
  {
    "declancm/maximize.nvim",
    keys = {
      {
        "<leader>wm",
        function()
          require("maximize").toggle()
        end,
        desc = "Maximize / Restore current split window",
      },
      {
        "<leader>z",
        function()
          require("maximize").toggle()
        end,
        desc = "Maximize / Restore current split window (Zoom)",
      },
    },
    opts = {},
  },
}
