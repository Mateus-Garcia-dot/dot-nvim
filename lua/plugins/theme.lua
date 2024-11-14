local on_highlights = function (h1, c)
	h1.TelescopeNormal = {
		fg = c.fg_dark,
	}
	h1.TelescopeBorder = {
		fg = c.bg_dark,
	}
	vim.api.nvim_set_hl(0, "TelescopeNormal", { bg="none" })
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
