local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local highlight_yank_group = vim.api.nvim_create_augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = highlight_yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

vim.cmd.colorscheme('tokyonight-night')

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "norg", "text" },
  callback = function() vim.opt_local.spell = true end,
})

-- filename statusline only for real, plain file buffers -- not oil (buftype
-- acwrite), neogit/diffview (nofile), terminal, telescope (prompt),
-- quickfix, help, etc.
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen", "BufEnter" }, {
  callback = function(args)
    -- statusline = "" means "use nvim's default format", not "show
    -- nothing" -- a single space is what actually renders blank.
    vim.wo.statusline = vim.bo[args.buf].buftype == "" and "%f" or " "
  end,
})
