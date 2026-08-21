return {
  "echasnovski/mini.animate",
  opts = {
    -- Disable scroll animation: smooth scrolling causes continuous viewport redraws
    -- that overwhelm terminal graphics protocols (Kitty/image.nvim), causing frozen or ghosted images.
    scroll = {
      enable = false,
    },
  },
}
