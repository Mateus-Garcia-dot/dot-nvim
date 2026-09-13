-- Watchman scales to large repos better than libuv's recursive fs_event;
-- falls back to nvim's default (capability disabled) if not installed.
local M = {}

function M.apply()
  local available = vim.fn.executable("watchman-wait") == 1
  if not available then
    return false
  end

  local watchfiles = require("vim.lsp._watchfiles")
  local watch = require("vim._watch")
  local uv = vim.uv

  watchfiles._watchfunc = function(path, opts, callback)
    opts = opts or {}
    path = vim.fs.normalize(path)

    local function skip(fullpath)
      if opts.include_pattern and opts.include_pattern:match(fullpath) == nil then
        return true
      end
      if opts.exclude_pattern and opts.exclude_pattern:match(fullpath) ~= nil then
        return true
      end
      return false
    end

    local buf = ""
    local obj = vim.system({ "watchman-wait", "--relative", path, "--max-events", "0", path }, {
      stdout = function(err, data)
        if err or not data then
          return
        end
        buf = buf .. data
        local lines = vim.split(buf, "\n", { plain = true })
        buf = table.remove(lines) or ""
        for _, line in ipairs(lines) do
          if line ~= "" then
            local fullpath = vim.fs.normalize(vim.fs.joinpath(path, line))
            if not skip(fullpath) then
              uv.fs_stat(fullpath, function(_, stat)
                local change_type = stat and watch.FileChangeType.Changed or watch.FileChangeType.Deleted
                callback(fullpath, change_type)
              end)
            end
          end
        end
      end,
      stderr = function(err, data)
        if not err and data and #vim.trim(data) > 0 then
          vim.schedule(function()
            vim.notify("watchman-wait: " .. data, vim.log.levels.ERROR)
          end)
        end
      end,
    })

    return function()
      obj:kill(2)
    end
  end

  return true
end

return M
