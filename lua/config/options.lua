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
vim.opt.number = true
vim.opt.relativenumber = true

-- keep undo history across sessions (~/.local/state/nvim/undo)
vim.opt.undofile = true

-- keep some context above/below the cursor instead of scrolling right to
-- the window edge
vim.opt.scrolloff = 8

-- always reserve one signcolumn (diagnostics, gitsigns) so text doesn't
-- jump sideways when a sign appears/disappears
vim.opt.signcolumn = "yes"

-- per-window statusline (just the filename -- set per-buftype in
-- autocmds.lua) instead of a single global one
vim.opt.laststatus = 2
vim.opt.cmdheight = 0

-- nvim 0.12's experimental replacement for the message area and cmdline:
-- no "Press ENTER" prompts, :messages opens in a real buffer, and (with
-- cmdheight=0 above) :echo output and errors show in a small float at the
-- bottom right for a few seconds instead of pushing the cmdline open.
-- vim.notify still goes to snacks' notifier. A no-op in headless runs, so
-- scripted `nvim --headless` output still reaches stdout. Delete this if it
-- misbehaves -- it's still marked experimental.
require("vim._core.ui2").enable({ msg = { targets = "msg" } })

-- ...and keep that float for messages worth reading. With the legacy UI,
-- cmdheight=0 silently swallowed routine chatter that ui2 now shows every
-- time:
-- - :w's `"file" 246L, 9136B written`: 0.12 sends it as a progress message,
--   and an empty "progress:" keeps those out of the message area
-- - "3 fewer lines" / "4 lines yanked" / "3 lines >ed" / ":s" counts:
--   'report' is their line-count threshold, and 9999 is effectively never
-- Undo/redo's "1 line less; before #12" has no option; keymaps.lua silences
-- it on u / <C-r>. Errors, warnings and search counts still show.
vim.o.messagesopt = (vim.o.messagesopt:gsub("progress:c", "progress:"))
vim.o.report = 9999

-- no wrap
vim.o.wrap = false

-- fold by syntax (methods, classes, blocks) from the treesitter folds
-- queries nvim-treesitter installs; a buffer with no parser just gets no
-- folds. Set globally rather than per buffer so it also covers buffers
-- loaded off-screen (an LSP rename touching other files) -- core's foldexpr
-- remembers "no parser here" after the first line, so that costs nothing.
-- Files open fully unfolded; foldtext="" keeps a closed fold's first line
-- syntax-highlighted.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99
vim.o.foldtext = ""

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
