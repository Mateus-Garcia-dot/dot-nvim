return {
  {
    -- mirrors the (already filename-only) statusline into the tmux status
    -- bar and hides nvim's own, instead of showing it twice
    "vimpostor/vim-tpipeline",
    lazy = false,
    init = function()
      -- keep full manual control of status-left/status-right so this
      -- doesn't clobber the gitmux segment / theme.tmux styling
      vim.g.tpipeline_autoembed = 0
    end,
  },
}
