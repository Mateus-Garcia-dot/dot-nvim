-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- indent options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- set numbering
vim.opt.relativenumber = true

-- always reserve one signcolumn (diagnostics, gitsigns) so text doesn't
-- jump sideways when a sign appears/disappears
vim.opt.signcolumn = "yes"

-- per-window statusline (just the filename -- set per-buftype in
-- autocmds.lua) instead of a single global one
vim.opt.laststatus = 2
vim.opt.cmdheight = 0

-- no wrap
vim.o.wrap = false

-- never show the native tabline (defaults to appearing once there are 2+
-- tabs); workspaces are switched via <leader>l1..9, no visible tab bar
vim.o.showtabline = 0

-- rounded border on every floating window (hover, signature help, code
-- action menu, ...) that doesn't explicitly set its own
vim.o.winborder = "rounded"

-- spellcheck (enabled per filetype in autocmds.lua, off by default in code)
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"
vim.opt.spell = false

-- force english
vim.cmd.language("en_US")

-- allow per-project local config (.nvim.lua / .nvimrc / .exrc), trust-prompted
-- on first read via vim.secure -- lets project-local files (kept out of git,
-- see dot-emacs' equivalent .dir-locals.el convention) register DAP configs,
-- test runners, etc. without touching this shared config.
vim.o.exrc = true
