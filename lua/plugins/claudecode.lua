return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  -- `cmd` lets lazy.nvim create command stubs that load the plugin on first
  -- use, so `:ClaudeCode` and friends work on a fresh start.
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  -- <leader>cs/<leader>cl are already Trouble (symbols/lsp panel), so
  -- Claude's keys avoid those two.
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude", mode = { "n", "v" } },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude", mode = { "n", "v" } },
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude", mode = { "n", "v" } },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude", mode = { "n", "v" } },
    { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model", mode = { "n", "v" } },
    { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer", mode = { "n", "v" } },
    { "<leader>ca", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>ca",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "oil" },
    },
    -- Diff management
    { "<leader>cA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff", mode = { "n", "v" } },
    { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff", mode = { "n", "v" } },
  },
}
