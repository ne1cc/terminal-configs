return {
  -- Tokyo Night (Deep midnight style matching Alacritty, Ghostty, and Tmux #1a1b26)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- Deep midnight theme
      transparent = true, -- True transparency so terminal glass blur & translucency show through
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        comments = { italic = true },
        keywords = { italic = true, bold = true },
        functions = { bold = true },
      },
      on_highlights = function(hl, c)
        -- Vibrant contrast against translucent background
        hl.Normal = { bg = "none", fg = c.fg }
        hl.NormalNC = { bg = "none", fg = c.fg_dark }
        hl.NormalFloat = { bg = "none", fg = c.fg }
        hl.FloatBorder = { bg = "none", fg = c.blue0 }
        hl.NeoTreeNormal = { bg = "none" }
        hl.NeoTreeNormalNC = { bg = "none" }
        hl.NeoTreeEndOfBuffer = { bg = "none" }
        hl.NeoTreeWinSeparator = { fg = c.border_highlight, bg = "none" }
        hl.WinSeparator = { fg = c.border_highlight, bg = "none" }
        hl.LineNr = { fg = c.dark3, bold = false }
        hl.CursorLineNr = { fg = c.cyan, bold = true }
        hl.DiagnosticVirtualTextError = { bg = "none", fg = c.red1 }
        hl.DiagnosticVirtualTextWarn = { bg = "none", fg = c.yellow }
        hl.DiagnosticVirtualTextInfo = { bg = "none", fg = c.blue1 }
        hl.DiagnosticVirtualTextHint = { bg = "none", fg = c.teal }
      end,
    },
  },

  -- Tell LazyVim to use tokyonight-night
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
