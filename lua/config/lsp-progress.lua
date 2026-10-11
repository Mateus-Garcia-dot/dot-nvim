-- LSP $/progress ("Loading workspace", phpactor indexing, ...) as one snacks
-- notification per server, updated in place. cmdheight=0 (options.lua) leaves
-- nowhere else for it to show, and a server that's still indexing -- and so
-- answers go-to-definition with nothing -- otherwise looks exactly like one
-- that's broken. Adapted from snacks' notifier docs.
local M = {}

local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

function M.setup()
  -- client id -> its in-flight progress tokens, each with its latest line
  ---@type table<integer, {token: lsp.ProgressToken, msg: string, done: boolean}[]>
  local progress = vim.defaulttable()

  vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("lsp_progress", { clear = true }),
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value
      if not client or type(value) ~= "table" then
        return
      end

      local p = progress[client.id]
      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ("[%3d%%] %s%s"):format(
              value.kind == "end" and 100 or value.percentage or 100,
              value.title or "",
              value.message and (" **%s**"):format(value.message) or ""
            ),
            done = value.kind == "end",
          }
          break
        end
      end

      -- every token's latest line makes it into this update; finished ones
      -- are dropped afterwards so the next update doesn't repeat them
      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)

      vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, {
        id = "lsp_progress:" .. client.id,
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and "✓ "
            or SPINNER[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #SPINNER + 1]
        end,
      })
    end,
  })
end

return M
