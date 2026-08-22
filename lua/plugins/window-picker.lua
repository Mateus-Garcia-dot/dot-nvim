-- ace-delete-window equivalent
return {
  "s1n7ax/nvim-window-picker",
  name = "window-picker",
  keys = {
    {
      "<leader>wD",
      function()
        local win = require("window-picker").pick_window()
        if win then
          vim.api.nvim_win_close(win, false)
        end
      end,
      desc = "Ace delete window",
      mode = { "n", "v" },
    },
  },
  opts = {
    hint = "floating-big-letter",
    selection_chars = "ASDFGHJKL",
  },
}
