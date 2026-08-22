-- headlines.nvim only refreshes reactively (Syntax/TextChanged/InsertLeave/
-- WinScrolled autocmds), none of which reliably fire during a hover float's
-- short lifetime. Force one refresh right after the float opens so the
-- code-block background shows up there too, not just in real buffers.
local util = vim.lsp.util
local orig_open_floating_preview = util.open_floating_preview

util.open_floating_preview = function(contents, syntax, opts, ...)
  local bufnr, winid = orig_open_floating_preview(contents, syntax, opts, ...)
  if syntax == "markdown" then
    local ok, headlines = pcall(require, "headlines")
    if ok and winid and vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_call(winid, function()
        headlines.refresh()
      end)
    end
  end
  return bufnr, winid
end
