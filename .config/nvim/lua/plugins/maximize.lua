return {
  "declancm/maximize.nvim",
  config = true,
  keys = {
    { "<leader>z", function() require("maximize").toggle() end, desc = "Toggle Maximize Window" },
    { "<C-w>z", function() require("maximize").toggle() end, desc = "Toggle Maximize Window" },
    { "<C-w>m", function() require("maximize").toggle() end, desc = "Toggle Maximize Window" },
  },
}
