return {
  -- 1. Sticky Class/Function context header when scrolling large code files
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
  },

  -- 2. Powerful surround actions (ysiw", cs"', ds")
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- 3. Translucent & clean Bufferline styling
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
        separator_style = "thin",
      },
      highlights = {
        fill = { bg = "none" },
        background = { bg = "none" },
        separator = { bg = "none" },
        separator_selected = { bg = "none" },
        tab = { bg = "none" },
        tab_selected = { bg = "none" },
      },
    },
  },

  -- 4. Transparent & sleek Lualine status bar matching Tokyo Night
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "tokyonight"
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "│", right = "│" }
    end,
  },

  -- 5. Snacks Enhancements: Smooth scroll & visual polish
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = true },
      words = { enabled = true },
      statuscolumn = { enabled = true },
      quickfile = { enabled = true },
    },
  },
}
