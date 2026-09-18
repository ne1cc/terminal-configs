-- MCPHub and OpenWiki MCP Integration for AstroNvim / lazy.nvim
-- Registers ravitemer/mcphub.nvim to expose MCP tools to Neovim.

return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",
    config = function()
      require("mcphub").setup({
        -- Port or config options for mcphub
        port = 3737,
      })
    end,
  },

  -- ============================================================================
  -- AI Integration Snippets (CodeCompanion / Avante)
  -- ============================================================================
  -- TODO: MANUAL REVIEW AND UNCOMMENTING REQUIRED.
  -- The blocks below wire mcphub MCP tools (including OpenWiki) into CodeCompanion
  -- or Avante. They are intentionally commented out because activating them changes
  -- AI chat tool-approval behavior and requires explicit review.
  --
  -- [CodeCompanion Integration Example]
  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {
  --     strategies = {
  --       chat = {
  --         tools = {
  --           ["mcp"] = {
  --             callback = "mcphub.extensions.codecompanion",
  --             description = "Call tools from MCP servers via MCPHub",
  --             -- CAUTION: Do NOT set requires_approval = false
  --             opts = {
  --               requires_approval = true,
  --             },
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
  --
  -- [Avante Integration Example]
  -- {
  --   "yetone/avante.nvim",
  --   opts = {
  --     -- Wire mcphub tools into Avante providers:
  --     -- Note: Keep human confirmation enabled when calling external MCP tools.
  --   },
  -- },
}
