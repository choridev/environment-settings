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
opt.clipboard = "unnamedplus"
opt.mouse:append("a")
opt.undofile = true
opt.updatetime = 200
opt.timeoutlen = 400
