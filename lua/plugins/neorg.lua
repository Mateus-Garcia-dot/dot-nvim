return {
	{
		"nvim-neorg/neorg",
		lazy = false,
		version = "*",
		config = {
			load = {
				["core.defaults"] = {},
				["core.export"] = {},
				["core.export.markdown"] = {},
				["core.concealer"] = {
					config = {
						icon_preset = "diamond",
					},
				},
			}
		},
	}
}
