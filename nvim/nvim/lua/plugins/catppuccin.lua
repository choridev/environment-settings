return {
	"catppuccin/nvim",
	name = "catppuccin", -- Without this, lazy.nvim would install it as "nvim"
	lazy = false, -- A colorscheme must always be loaded
	priority = 1000, -- Load before every other plugin so highlights are ready
	opts = {
		flavour = "auto",
		background = { light = "latte", dark = "frappe" },
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
