return {
  "3rd/image.nvim",
  event = "VeryLazy",
  opts = {
    backend = "kitty", -- Supported natively by Ghostty / Kitty
    processor = "magick_cli", -- Uses ImageMagick directly to avoid conversion errors
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true, -- Clear image while editing text on that line
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" },
      },
      neotree = {
        enabled = true,
      },
    },
    max_width = 80,
    max_height = 20,
    max_width_window_percentage = 60,
    max_height_window_percentage = 40,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = true,
    tmux_show_only_in_active_window = true,
  },
  config = function(_, opts)
    local image = require("image")
    image.setup(opts)

    -- Auto-clear graphics overlays when switching buffers or windows
    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufHidden" }, {
      group = vim.api.nvim_create_augroup("ImageNvimClearOnLeave", { clear = true }),
      callback = function()
        image.clear()
      end,
    })

    -- Add keymap <leader>ic to manually clear ghost image overlays
    vim.keymap.set("n", "<leader>ic", function()
      image.clear()
      vim.cmd("redraw!")
    end, { desc = "Clear image overlays" })
  end,
}

