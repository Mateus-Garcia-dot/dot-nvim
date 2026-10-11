return {
  "smart-splits-nvim/smart-splits.nvim",
  -- must not lazy-load: the tmux backend marks the pane as running nvim
  -- (@pane-is-vim) when it loads, and until then tmux swallows <C-hjkl>
  lazy = false,
  dependencies = {
    -- v3 moved multiplexer support out of core; the tmux half of this lives
    -- in ~/.config/tmux (the same repo doubles as its TPM plugin)
    "smart-splits-nvim/backend-tmux",
  },
  config = function()
    require("smart-splits").setup({
      mux = { backend = "smart-splits-backend-tmux" },
    })

    local s = require("smart-splits")
    local set = vim.keymap.set

    set("n", "<c-h>", s.move_cursor_left)
    set("n", "<c-j>", s.move_cursor_down)
    set("n", "<c-k>", s.move_cursor_up)
    set("n", "<c-l>", s.move_cursor_right)

    set("n", "<C-Left>", s.resize_left)
    set("n", "<C-Down>", s.resize_down)
    set("n", "<C-Up>", s.resize_up)
    set("n", "<C-Right>", s.resize_right)
  end,
}
