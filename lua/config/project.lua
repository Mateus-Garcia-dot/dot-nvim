-- Shared project-root helper (projectile-root equivalent).
local M = {}

function M.root()
  return vim.fs.root(0, ".git") or vim.uv.cwd()
end

return M
