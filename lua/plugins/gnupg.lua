return {
  'jamessan/vim-gnupg',
  -- must load at startup: it hooks BufReadCmd, so BufReadPre never fires for these files
  lazy = false,
  init = function()
    vim.g.GPGPreferArmor = 1
    vim.g.GPGPreferSign = 0
    vim.g.GPGUsePipes = 1
  end,
}
