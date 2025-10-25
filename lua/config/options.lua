-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable 24-bit color
vim.opt.termguicolors = true

-- indent options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- line numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- no status bar
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

-- disable line wrapping
vim.opt.wrap = false

-- better editing experience
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- better search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- better splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- persistent undo
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- better completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- update time for better experience
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- force english
vim.cmd("language en_US")
