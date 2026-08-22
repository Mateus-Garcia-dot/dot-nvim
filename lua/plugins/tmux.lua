return {
  {
    "christoomey/vim-tmux-navigator",
    -- The plugin's own built-in mappings send raw keystrokes into terminal
    -- jobs (an <expr> tnoremap resolving to "<C-w>:TmuxNavigateLeft<cr>" as
    -- literal characters). Whatever CLI is running in that terminal (e.g.
    -- Claude Code) has no idea what <C-w>: means and just types/submits
    -- those characters as a message. Disable them; the `keys` below use
    -- <cmd>...<cr>, which runs the Ex command directly through Neovim's
    -- dispatcher and never touches the terminal job's input at all.
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    -- <C-U> has no place inside <cmd>...<cr>: that's an old-style-mapping
    -- hack ("<C-U> clears a stray count before a `:...<CR>` command line")
    -- that means nothing to <cmd>, which bypasses the cmdline entirely --
    -- it just prepends a literal Ctrl-U byte to the command name, breaking
    -- it ("E492: Not an editor command: ^UTmuxNavigateLeft").
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
      -- terminal-mode versions (toggleterm, Claude's terminal, etc.): plain
      -- <c-h> etc. only fire in normal mode, so inside a terminal buffer
      -- they'd just send a literal backspace/keystroke to the shell instead
      -- of navigating. Escape terminal-mode first, then run the same command.
      { "<c-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", mode = "t" },
      { "<c-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", mode = "t" },
      { "<c-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", mode = "t" },
      { "<c-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", mode = "t" },
      { "<c-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>", mode = "t" },
    },
  },
}
