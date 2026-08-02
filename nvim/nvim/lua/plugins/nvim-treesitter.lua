return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- the `require("nvim-treesitter").install()` API below is main-branch only
	lazy = false, -- registers the FileType autocmd, so it has to run before the first buffer
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"lua",
			"python",
			"go",
			"yaml",
			"toml",
			"json",
			"dockerfile",
			"markdown",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
