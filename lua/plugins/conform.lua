-- :ConformInfo to view configured and available formatters, as well as log file
local config = function()
  local conform = require("conform")

  conform.setup({
    -- none configured: :Format falls back to the language server's own
    -- formatting (lsp_format = "fallback" below) until a filetype gets an
    -- entry here
    formatters_by_ft = {},
  })
  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
  end, { range = true })
end

return {
  "stevearc/conform.nvim",
  enabled = true,
  config = config,
  cmd = { "ConformInfo", "Format" },
}
