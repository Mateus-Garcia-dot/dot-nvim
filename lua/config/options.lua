-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- indent options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.expandtab = true

-- set numbering
vim.opt.relativenumber = true

-- no status bar
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

-- no wrap
vim.o.wrap = false

-- force english
vim.api.nvim_exec("language en_US", true)
