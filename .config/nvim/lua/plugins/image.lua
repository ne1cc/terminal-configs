return {
  "3rd/image.nvim",
  ft = { "markdown", "vimwiki" },
  event = "VeryLazy",
  opts = {
    backend = "kitty", -- Supported natively by Ghostty / Kitty
    processor = "magick_cli", -- Uses ImageMagick directly to avoid conversion errors
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" },
        resolve_image_path = function(document_path, image_path, fallback)
          -- URL-decode paths (e.g. %20 -> space) so files pasted with %20 are found on disk
          local decoded = image_path:gsub("%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
          end)
          return fallback(document_path, decoded)
        end,
      },
      neotree = {
        enabled = false,
      },
    },
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = 100,
    max_height_window_percentage = 100,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = false,
    tmux_show_only_in_active_window = true,
  },
  config = function(_, opts)
    local image = require("image")
    image.setup(opts)

    -- Add keymap <leader>ic to manually clear ghost image overlays
    vim.keymap.set("n", "<leader>ic", function()
      image.clear()
      vim.cmd("redraw!")
    end, { desc = "Clear image overlays" })
  end,
}

