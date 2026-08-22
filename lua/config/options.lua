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

-- no status bar
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

-- no wrap
vim.o.wrap = false

-- winbar (file path above the buffer) is set per-buffer in autocmds.lua --
-- only real file buffers get one, not oil/neogit/terminal/etc.

-- rounded border on every floating window (hover, signature help, code
-- action menu, ...) that doesn't explicitly set its own
vim.o.winborder = "rounded"

-- spellcheck (enabled per filetype in autocmds.lua, off by default in code)
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"
vim.opt.spell = false

-- force english
vim.cmd.language("en_US")
