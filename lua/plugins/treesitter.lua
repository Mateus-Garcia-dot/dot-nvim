local ensure = {
  "elixir",
  "eex",
  "heex",
  "bash",
  "lua",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    init = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = ensure,
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
      vim.treesitter.language.register("bash", "zsh")
    end,
  },
}
