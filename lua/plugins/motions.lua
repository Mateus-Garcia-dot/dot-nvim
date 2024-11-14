local function config()
  require('eyeliner').setup({
      highlight_on_key = false,
      dim = true,
      max_length = 9999,
      disabled_filetypes = {},
      disabled_buftypes = {},
      default_keymaps = true,
  })

  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
      vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
    end,
  })
end

return {
  {
    "jinh0/eyeliner.nvim",
    lazy = false,
    config = config
  },
}
