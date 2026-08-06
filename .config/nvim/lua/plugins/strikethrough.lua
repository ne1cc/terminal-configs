return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      v = {
        ["<Leader>~"] = { "c~~<C-r>"~~<Esc>", desc = "Strikethrough text" },
        ["<Leader>ms"] = { "c~~<C-r>"~~<Esc>", desc = "Strikethrough text" },
      },
    },
  },
}
