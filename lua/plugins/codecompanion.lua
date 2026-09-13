return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  opts = {
    strategies = {
      chat = { adapter = "claude_code" },
      inline = { adapter = "claude_code" },
    },
  },
  -- <leader>cs/<leader>cl are already Trouble (symbols/lsp panel) -- same
  -- <leader>c* layout claudecode.nvim used to occupy.
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat", mode = { "n", "v" } },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Action palette", mode = { "n", "v" } },
    { "<leader>ci", "<cmd>CodeCompanion<cr>", desc = "Inline edit", mode = { "n", "v" } },
  },
}
