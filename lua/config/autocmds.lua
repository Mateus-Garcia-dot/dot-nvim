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
