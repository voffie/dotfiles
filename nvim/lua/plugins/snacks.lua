local macchiato = require("catppuccin.palettes").get_palette("macchiato")
vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = macchiato.mauve })

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			git = { enabled = true },
			gitbrowse = { enabled = true },
			indent = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
	},
}
