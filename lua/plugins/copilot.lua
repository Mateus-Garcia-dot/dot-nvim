return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 50,
					keymap = {
						accept = "<C-l>",
					},
				},
				filetypes = {
					gitcommit = true, -- allow specific filetype
					["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
				},
			})
		end,
	}
}
