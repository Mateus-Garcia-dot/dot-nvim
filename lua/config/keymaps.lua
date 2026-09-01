local set = vim.keymap.set
local project_root = require("config.project").root

set({ 'n', 'v' }, '+', '"+', { silent = true })

set({ 'n', 'v' }, '<leader>ss', 'z=', { desc = "Correct spelling" })

-- windows (windmove equivalent; ace-delete-window is in plugins/window-picker.lua)
set({ 'n', 'v' }, '<leader>wh', '<C-w>h', { desc = "Window left" })
set({ 'n', 'v' }, '<leader>wj', '<C-w>j', { desc = "Window down" })
set({ 'n', 'v' }, '<leader>wk', '<C-w>k', { desc = "Window up" })
set({ 'n', 'v' }, '<leader>wl', '<C-w>l', { desc = "Window right" })
set({ 'n', 'v' }, '<leader>w/', '<C-w>v', { desc = "Split right" })
set({ 'n', 'v' }, '<leader>w-', '<C-w>s', { desc = "Split below" })
set({ 'n', 'v' }, '<leader>wd', '<C-w>c', { desc = "Delete window" })

-- dired-jump equivalent: Oil at the current file's directory, not cwd
set({ 'n', 'v' }, '<leader>fj', function()
  require("oil").open(vim.fn.expand("%:p:h"))
end, { desc = "Jump to file's directory" })

-- shell-command equivalents
set({ 'n', 'v' }, '<leader>!!', function()
  vim.ui.input({ prompt = "Run in root: " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd(("TermExec cmd=%s dir=%s"):format(vim.fn.shellescape(cmd), vim.fn.shellescape(project_root())))
    end
  end)
end, { desc = "Run shell command in project root" })

set({ 'n', 'v' }, '<leader>!.', function()
  vim.ui.input({ prompt = "$ " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd("!" .. cmd)
    end
  end)
end, { desc = "Run shell command here" })

-- projectile-toggle-between-implementation-and-test equivalent. Global, so it
-- works in python/ts/ruby/etc; php shadows both keys with a buffer-local
-- version in ftplugin/php.lua that keys off the class name instead.
for _, lhs in ipairs({ '<leader>tc', '<leader>pt' }) do
  set({ 'n', 'v' }, lhs, function()
    require("config.test-toggle").toggle()
  end, { desc = "Toggle source/test" })
end

-- org-present equivalent
set({ 'n', 'v' }, '<leader>op', "<cmd>Neorg presenter start<cr>", { desc = "Present" })

-- save-buffers-kill-emacs equivalent (confirms before discarding unsaved buffers)
set({ 'n', 'v' }, '<leader>qq', "<cmd>confirm qa<cr>", { desc = "Quit" })

-- tmux/Spacemacs-layout style numbered workspaces, backed by tabpages.
set({ 'n', 'v' }, '<leader>lc', '<cmd>tabnew<cr>', { desc = "New workspace" })

-- Switches if workspace N exists; no-op otherwise (matches tmux: it
-- doesn't create window N just because you pressed its number).
for i = 1, 9 do
  set({ 'n', 'v' }, '<leader>l' .. i, function()
    if i <= vim.fn.tabpagenr('$') then
      vim.cmd(i .. 'tabnext')
    end
  end, { desc = "Workspace " .. i })
end
