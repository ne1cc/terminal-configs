-- ftplugin for mermaid and mmd files
local opts = { silent = true, buffer = true }
local map = vim.keymap.set

-- Browser preview for mermaid
map("n", "<leader>mp", function()
  vim.cmd("MarkdownPreviewToggle")
end, vim.tbl_extend("force", opts, { desc = "Mermaid browser preview" }))

-- Dedicated tab preview (full-width)
map("n", "<leader>md", function()
  require("plugins.diagram").show_diagram_tab()
end, vim.tbl_extend("force", opts, { desc = "Show diagram in dedicated full-width tab" }))

-- Open diagram directly in macOS system viewer (Preview)
map("n", "<leader>mo", function()
  require("plugins.diagram").open_system_viewer()
end, vim.tbl_extend("force", opts, { desc = "Open diagram in system viewer" }))

-- Toggle in-buffer rendering (fills entire terminal page)
map("n", "<leader>mb", function()
  require("plugins.diagram").render_full_width()
end, vim.tbl_extend("force", opts, { desc = "Toggle diagram in-buffer (fills terminal page)" }))

-- Clear image overlays
map("n", "<leader>ic", function()
  pcall(function()
    require("plugins.diagram").clear_custom_images(vim.api.nvim_get_current_buf())
  end)
  local clear_seq = "\x1b_Ga=d,d=A\x1b\\"
  if vim.env.TMUX then
    clear_seq = "\x1bPtmux;\x1b\x1b_Ga=d,d=A\x1b\x1b\\\x1b\\"
  end
  io.stdout:write(clear_seq)
  io.stdout:flush()
  vim.cmd("redraw!")
  vim.notify("Cleared all image and diagram overlays", vim.log.levels.INFO, { title = "Image Overlays" })
end, vim.tbl_extend("force", opts, { desc = "Clear image overlays" }))
