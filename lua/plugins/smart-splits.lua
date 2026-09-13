return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({
      multiplexer_integration = "tmux",
    })

    local s = require("smart-splits")
    local set = vim.keymap.set

    set("n", "<c-h>", s.move_cursor_left)
    set("n", "<c-j>", s.move_cursor_down)
    set("n", "<c-k>", s.move_cursor_up)
    set("n", "<c-l>", s.move_cursor_right)
    set("n", "<c-\\>", s.move_cursor_previous)

    set("n", "<C-Left>", s.resize_left)
    set("n", "<C-Down>", s.resize_down)
    set("n", "<C-Up>", s.resize_up)
    set("n", "<C-Right>", s.resize_right)
  end,
}
