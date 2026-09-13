-- Uses Mason's php-debug-adapter package (xdebug/vscode-php-debug) so this
-- config no longer depends on ~/.config/dot-emacs's makefile build.
local M = {}

local function adapter_path()
  local registry = require("mason-registry")
  if not registry.is_installed("php-debug-adapter") then
    return nil
  end
  return registry.get_package("php-debug-adapter"):get_install_path() .. "/extension/out/phpDebug.js"
end

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
  local path = adapter_path()
  if not path then
    vim.notify(
      "php-debug-adapter not installed -- run `:MasonInstall php-debug-adapter`.",
      vim.log.levels.WARN
    )
    return
  end

  require("dap").adapters.php = {
    type = "executable",
    command = "node",
    args = { path },
  }
end

return M
