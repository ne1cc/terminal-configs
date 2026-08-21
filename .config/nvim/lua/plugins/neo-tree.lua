return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    commands = {
      open_mupdf = function(state)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        if filepath and node.type == "file" then
          vim.fn.jobstart({ "mupdf", filepath }, { detach = true })
        end
      end,
    },
    window = {
      width = 40,
      position = "left",
      mappings = {
        ["<CR>"] = "open",
        ["o"] = "open",
        ["P"] = "toggle_preview",
        ["M"] = "open_mupdf",
      },
    },
  },
}
