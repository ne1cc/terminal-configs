return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep (Ripgrep)" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>fr", "<cmd>FzfLua lsp_references<cr>", desc = "LSP References" },
  },
  opts = {
    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
      preview = {
        layout = "flex",
        horizontal = "right:50%",
      },
    },
    keymap = {
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
  },
}
