return {
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume session" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue session" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file from tree",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
			},
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},
}
