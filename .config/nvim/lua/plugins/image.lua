return {
  "3rd/image.nvim",
  event = "VeryLazy",
  opts = {
    backend = "kitty", -- Supported natively by Ghostty
    processor = "magick_cli", -- Uses ImageMagick directly to avoid conversion errors
    integrations = {
      markdown = { enabled = true },
      neotree = { enabled = true },
    },
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = 80,
    max_height_window_percentage = 80,
    window_overlap_clear_enabled = true,
    window_overlap_clear_target_buffer_fan_out_length = 0,
  },
}
