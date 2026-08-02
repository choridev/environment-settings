return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	-- Deferred to VeryLazy instead of `cmd = "Telescope"` so that ui-select still
	-- takes over `vim.ui.select` without waiting for the first picker to open.
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- optional but recommended
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-ui-select.nvim",
	},
	opts = function()
		return {
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						-- even more opts
					}),
				},
			},
		}
	end,
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		telescope.load_extension("ui-select")
		-- fzf-native needs a compiler; skip it rather than break startup.
		if not pcall(telescope.load_extension, "fzf") then
			vim.notify("telescope-fzf-native is unavailable; run :Lazy build telescope-fzf-native.nvim", vim.log.levels.WARN)
		end
	end,
}
