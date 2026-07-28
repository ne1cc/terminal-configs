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
    vim.g.lazygit_floating_window_scaling_factor = 0.9
  end,
  keys = {
    { "<leader><C-g>", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    { "<leader>tl", "<cmd>LazyGit<cr>", desc = "Toggle LazyGit" },
  },
}
