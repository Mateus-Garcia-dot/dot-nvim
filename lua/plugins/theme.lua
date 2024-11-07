return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
		priority = 1001,
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
		priority = 1000,
    opts = {
			transparent = vim.g.transparent_enabled,
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night"
		}
	}
}
