-- vterm-toggle equivalent: Tt toggles a scratch float, Tn always opens a new one
local terminal_count = 1

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { "<leader>Tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle terminal" },
    {
      "<leader>Tn",
      function()
        terminal_count = terminal_count + 1
        vim.cmd(terminal_count .. "ToggleTerm direction=float")
      end,
      desc = "New terminal",
    },
  },
  opts = {
    direction = "float",
    close_on_exit = true,
    float_opts = { border = "curved" },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function() vim.cmd("startinsert") end,
    })
  end,
}
