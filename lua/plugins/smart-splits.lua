-- Replaces vim-tmux-navigator: same seamless nvim<->tmux pane crossing on
-- <c-hjkl>, plus resizing panes across that same boundary on Ctrl-arrows.
-- Alt isn't available on this keyboard, and Ctrl-Shift-<letter> is
-- physically indistinguishable from plain Ctrl-<letter> in most terminals
-- (a control byte doesn't encode Shift) without an extended keyboard
-- protocol (Kitty protocol / xterm modifyOtherKeys) -- Ctrl-arrow avoids
-- both problems since arrow-key modifiers are encoded numerically in the
-- escape sequence itself and are universally supported. Needs matching
-- tmux-side config (dot-tmux's tmux.conf: @plugin
-- 'mrjones2014/smart-splits.nvim' plus the @smart-splits_resize_*_key
-- overrides to match).
return {
  "mrjones2014/smart-splits.nvim",
  -- must not be lazy-loaded: it sets a tmux variable on startup
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

    -- smart-splits doesn't handle terminal buffers itself (normal mode
    -- only); escape terminal-mode first, then call the same function.
    -- :stopinsert does NOT exit terminal-job mode (verified); the "x"
    -- feedkeys flag (synchronous execute) is what actually works here --
    -- "n" alone doesn't process the keys in time.
    local escape_terminal = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
    local function t(fn)
      return function()
        vim.api.nvim_feedkeys(escape_terminal, "x", false)
        fn()
      end
    end
    set("t", "<c-h>", t(s.move_cursor_left))
    set("t", "<c-j>", t(s.move_cursor_down))
    set("t", "<c-k>", t(s.move_cursor_up))
    set("t", "<c-l>", t(s.move_cursor_right))
    set("t", "<c-\\>", t(s.move_cursor_previous))
  end,
}
