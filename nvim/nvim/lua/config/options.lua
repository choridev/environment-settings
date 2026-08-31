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
	-- Read back from Neovim's own register instead of querying the terminal.
	-- Terminals and tmux almost always refuse OSC 52 reads, so the query just
	-- stalls until it times out ("waiting for osc 52 response from the
	-- terminal..."). Writes still go out over OSC 52, which does work.
	local paste_from_register = function()
		return {
			vim.fn.split(vim.fn.getreg('"'), "\n"),
			vim.fn.getregtype('"'),
		}
	end
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = paste_from_register,
			["*"] = paste_from_register,
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
