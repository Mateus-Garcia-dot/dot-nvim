local on_highlights = function (h1, c)
  -- snacks.picker's floating windows use SnacksNormal/SnacksNormalNC (not a
  -- picker-specific group) for their background -- this replaces telescope's
  -- TelescopeNormal override now that snacks.picker is the fuzzy finder.
  h1.SnacksNormal = {
    fg = c.fg_dark,
  }
  h1.SnacksNormalNC = {
    fg = c.fg_dark,
  }
  vim.api.nvim_set_hl(0, "SnacksNormal", { bg="none" })
  vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg="none" })
end


return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal"
      }
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1001,
    opts = {
      style = "night",
      transparent = vim.g.transparent_enabled,
      on_highlights = on_highlights
    },
  }
}
