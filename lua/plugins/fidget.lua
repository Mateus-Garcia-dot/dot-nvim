return {
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      -- cmdheight=0 (options.lua) hides the message area, so a plain
      -- vim.notify (e.g. "client quit with exit code 1") would otherwise
      -- vanish unseen. Route it through fidget's toast instead.
      notification = { override_vim_notify = true },
    },
  },
}
