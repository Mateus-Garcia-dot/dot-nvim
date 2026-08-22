-- Shared project-root helper, backed by project.nvim's detection
-- (pattern/lsp based) instead of a bare .git lookup.
local M = {}

function M.root()
  local root = require("project_nvim.project").get_project_root()
  return root or vim.uv.cwd()
end

return M
