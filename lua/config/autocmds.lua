local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.opt.number = true
    vim.opt.relativenumber = false
  end,
})

autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = true
  end,
})

local highlight_yank_group = vim.api.nvim_create_augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = highlight_yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})
