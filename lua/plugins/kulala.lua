return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>rs", function() require("kulala").run() end, desc = "Send request", mode = { "n", "v" } },
    { "<leader>rt", function() require("kulala").toggle_view() end, desc = "Toggle request/response view" },
    { "<leader>rb", function() require("kulala").scratchpad() end, desc = "Open scratchpad" },
  },
  opts = {},
}
