return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- no language server is needed until a buffer exists
	opts = {
		ensure_installed = { "lua_ls", "yamlls", "taplo", "marksman", "gopls" },
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			cmd = "Mason",
			opts = {
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			},
		},
		{
			"neovim/nvim-lspconfig",
		},
	},
}
