-- Reuses the vscode-php-debug adapter built by ~/.config/dot-emacs's makefile
-- (`make dap-php`) instead of installing a second copy via mason.
local M = {}

M.adapter_path = vim.fn.expand("~/.config/dot-emacs/.lsp-servers/vscode-php-debug/out/phpDebug.js")

-- Call from a project-local config (exrc / .nvim.lua) to register a debug
-- config NAME mapping the container's /app to LOCAL_ROOT, e.g.:
--   require("config.dap-php").add_project("marvin", vim.fn.getcwd())
function M.add_project(name, local_root)
  local dap = require("dap")
  dap.configurations.php = dap.configurations.php or {}
  table.insert(dap.configurations.php, {
    name = name,
    type = "php",
    request = "launch",
    port = 9003,
    pathMappings = { ["/app"] = local_root },
    xdebugSettings = { max_depth = 10, max_data = 51200 },
    sourceMaps = true,
  })
end

function M.setup()
  if vim.fn.filereadable(M.adapter_path) == 0 then
    vim.notify(
      "vscode-php-debug adapter not found at " .. M.adapter_path ..
      " -- run `make dap-php` in ~/.config/dot-emacs to build it.",
      vim.log.levels.WARN
    )
    return
  end

  require("dap").adapters.php = {
    type = "executable",
    command = "node",
    args = { M.adapter_path },
  }
end

return M
