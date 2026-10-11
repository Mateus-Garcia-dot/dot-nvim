return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({})
    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>p", group = "project" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>c", group = "code" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "github" },
      { "<leader>t", group = "test" },
      { "<leader>T", group = "terminal" },
      { "<leader>d", group = "debug" },
      { "<leader>r", group = "rest" },
      { "<leader>s", group = "spell/symbols" },
      { "<leader>w", group = "windows" },
      { "<leader>u", group = "undo" },
      { "<leader>l", group = "lsp" },
      { "<leader>lg", group = "goto" },
      { "<leader>!", group = "shell" },
    })
  end,
}
