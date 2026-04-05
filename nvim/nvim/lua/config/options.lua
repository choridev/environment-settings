local opt = vim.opt

-- Indentation & Formatting
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.wrap = false
opt.encoding = "UTF-8"

-- UI & View
opt.number = true
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 5
opt.sidescrolloff = 8

-- Search & Replace
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Window & Pane
opt.splitbelow = true
opt.splitright = true

-- System & UX
if not vim.g.vscode then
	opt.clipboard = "unnamedplus"
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
else
	opt.clipboard = ""
	vim.g.clipboard = nil
end
opt.mouse:append("a")
opt.undofile = true
opt.updatetime = 200
opt.timeoutlen = 400
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
