return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    vim.g.lazygit_use_neovim_remote = 1
  end,
  keys = {
    { "<leader><C-g>", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
  },
}
