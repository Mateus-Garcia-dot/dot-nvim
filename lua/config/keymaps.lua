local set = vim.keymap.set
local project_root = require("config.project").root

set('n', '+', '"+', { silent = true })
set('v', '+', '"+', { silent = true })

set('n', '<leader>ss', 'z=', { desc = "Correct spelling" })

-- windows (windmove equivalent; ace-delete-window has no nvim analog)
set('n', '<leader>wh', '<C-w>h', { desc = "Window left" })
set('n', '<leader>wj', '<C-w>j', { desc = "Window down" })
set('n', '<leader>wk', '<C-w>k', { desc = "Window up" })
set('n', '<leader>wl', '<C-w>l', { desc = "Window right" })
set('n', '<leader>w/', '<C-w>v', { desc = "Split right" })
set('n', '<leader>w-', '<C-w>s', { desc = "Split below" })
set('n', '<leader>wd', '<C-w>c', { desc = "Delete window" })

-- dired-jump equivalent: Oil at the current file's directory, not cwd
set('n', '<leader>fj', function()
  require("oil").open(vim.fn.expand("%:p:h"))
end, { desc = "Jump to file's directory" })

-- shell-command equivalents
set('n', '<leader>!!', function()
  vim.ui.input({ prompt = "Run in root: " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd(("TermExec cmd=%s dir=%s"):format(vim.fn.shellescape(cmd), vim.fn.shellescape(project_root())))
    end
  end)
end, { desc = "Run shell command in project root" })

set('n', '<leader>!.', function()
  vim.ui.input({ prompt = "$ " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd("!" .. cmd)
    end
  end)
end, { desc = "Run shell command here" })

-- org-present equivalent
set('n', '<leader>op', "<cmd>Neorg presenter start<cr>", { desc = "Present" })

-- save-buffers-kill-emacs equivalent (confirms before discarding unsaved buffers)
set('n', '<leader>qq', "<cmd>confirm qa<cr>", { desc = "Quit" })
