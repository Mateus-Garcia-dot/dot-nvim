-- :ConformInfo to view configured and available formatters, as well as log file
local config = function()
  local conform = require("conform")

  conform.setup({
    formatters_by_ft = {
      javascript = { "prettierd", "eslint_d" },
      typescript = { "prettierd", "eslint_d" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      -- python = { "black" },
      json = { "prettierd" },
      vue = { "prettierd", "eslint_d" },
      lua = { "stylua" },
      markdown = { "markdownlint" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      yaml = { "yamlfmt" },
      -- ruby = { "standardrb" }, --currently broken, see autocmds.lua for workaround
    },

    -- format_on_save = {
    --   lsp_fallback = true,
    --   async = false,
    --   timeout_ms = 500,
    -- },
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
  event = { "BufWritePre" },
  config = config,
  cmd = { "ConformInfo" },
}
