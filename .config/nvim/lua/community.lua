-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Language packs
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.full-dadbod" },

  -- Community plugins
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.scrolling.mini-animate" },
  { import = "astrocommunity.fuzzy-finder.snacks-picker" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
  { import = "astrocommunity.motion.nvim-surround" },
}
