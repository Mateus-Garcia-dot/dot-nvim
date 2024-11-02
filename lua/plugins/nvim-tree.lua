local function on_attach_change(bufnr)
  local api = require("nvim-tree.api")

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "<c-n>", ":NvimTreeToggle<cr>", { silent = true })
end

return {
  {
    "nvim-tree/nvim-web-devicons",
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      on_attach = on_attach_change,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
  },
}
