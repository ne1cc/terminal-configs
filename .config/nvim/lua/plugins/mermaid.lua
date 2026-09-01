return {
  -- 1. In-browser live preview with full Mermaid diagram rendering
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown & Mermaid Live Preview" },
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown & Mermaid Live Preview" },
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
    end,
  },

  -- 2. Tree-sitter Mermaid parser for syntax highlighting inside markdown code blocks
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "mermaid" })
      end
    end,
  },

  -- 3. Standalone Mermaid filetype detection and syntax support (.mmd, .mermaid)
  {
    "mracos/mermaid.vim",
    ft = { "mermaid", "mmd" },
  },

  -- 4. Terminal image rendering support via image.nvim and ImageMagick
  --    Lazy-load on markdown filetypes: kitty-graphics rendering is only used there.
  {
    "3rd/image.nvim",
    ft = { "markdown", "vimwiki" },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- 5. mermaid.nvim: live browser preview (built-in server + SSE), mmdc lint
  --    diagnostics, buffer formatting, and inline terminal render. Inline
  --    rendering uses the kitty graphics protocol on Ghostty + nvim 0.12+
  --    (tmux allow-passthrough on) and falls back to chafa on older nvim.
  {
    "kevalin/mermaid.nvim",
    ft = { "mermaid", "mmd" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("mermaid").setup({
        lint = { enabled = true, command = "mmdc" },
        preview = { renderer = "mermaid.js", theme = "dark" },
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("mermaid_nvim_keys", { clear = true }),
        pattern = { "mermaid", "mmd" },
        callback = function(event)
          local buf = event.buf
          -- Buffer-local: shadows the global <leader>mp/<leader>mr markdown
          -- bindings only inside mermaid buffers.
          vim.keymap.set("n", "<leader>mp", "<cmd>MermaidPreview<CR>",
            { buffer = buf, desc = "Mermaid Preview" })
          vim.keymap.set("n", "<leader>mf", "<cmd>MermaidFormat<CR>",
            { buffer = buf, desc = "Mermaid Format" })
          vim.keymap.set("n", "<leader>mr", "<cmd>MermaidRender<CR>",
            { buffer = buf, desc = "Mermaid Render (inline)" })
          vim.keymap.set("n", "<leader>mc", "<cmd>MermaidCopyURL<CR>",
            { buffer = buf, desc = "Mermaid Copy URL" })
          vim.keymap.set("n", "<leader>mx", "<cmd>MermaidPreviewStop<CR>",
            { buffer = buf, desc = "Mermaid Stop Preview" })
        end,
      })
    end,
  },
}

-- Helper shortcut to view current buffer's mermaid diagrams or full markdown in browser
-- Keybinding: <leader>mv (Mermaid View)
