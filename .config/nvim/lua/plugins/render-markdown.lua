-- Word-wrap prose files: soft wrap that breaks at word boundaries, with a
-- hanging indent so wrapped lines align under the text rather than the gutter.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prose_wrap", { clear = true }),
  pattern = { "markdown", "vimwiki" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↪ "
  end,
})

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    opts = {
      enabled = true,
      render_modes = { "n", "c", "t" },
      file_types = { "markdown" },

      heading = {
        enabled = true,
        sign = true,
        position = "overlay",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "full",
        min_width = 0,
      },

      code = {
        enabled = true,
        sign = true,
        style = "full",
        position = "left",
        language_pad = 2,
        disable_background = { "default" },
        width = "full",
        min_width = 0,
        border = "thin",
        above = "▄",
        below = "▀",
        highlight = "RenderMarkdownCode",
        highlight_inline = "RenderMarkdownCodeInline",
      },

      dash = {
        enabled = true,
        icon = "─",
        width = "full",
      },

      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },

      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },

      pipe_table = {
        enabled = true,
        style = "full",
        cell = "padded",
        alignment_indicator = "━",
        border = {
          "┌", "┬", "┐",
          "├", "┼", "┤",
          "└", "┴", "┘",
          "│", "─",
        },
      },

      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
      },

      link = {
        enabled = true,
        image = "󰥶 ",
        hyperlink = "󰌹 ",
        custom = {
          web = { pattern = "^http", icon = "󰖟 " },
          file = { pattern = "^file:", icon = "󰈙 " },
        },
      },

      indent = {
        enabled = true,
        per_level = 2,
      },

      sign = {
        enabled = true,
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown buf_toggle<CR>", desc = "Toggle Markdown reader view" },
    },
  },
}
