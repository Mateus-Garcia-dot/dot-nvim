-- Shared project-root helper, backed by snacks.nvim's git-root detection
-- (same .git-pattern behavior project.nvim used, minus the extra plugin).
local M = {}

function M.root()
  return require("snacks").git.get_root() or vim.uv.cwd()
end

return M
