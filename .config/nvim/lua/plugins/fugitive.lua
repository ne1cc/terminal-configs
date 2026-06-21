return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gS", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
    { "<leader>gD", "<cmd>Git diff<cr>", desc = "Git diff (fugitive)" },
    { "<leader>gB", "<cmd>Git blame<cr>", desc = "Git blame (fugitive)" },
    { "<leader>gP", "<cmd>Git push<cr>", desc = "Git push (fugitive)" },
  },
}
