local mapKey = require("utils.keyMapper").mapKey

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>")

-- Telescope
mapKey("<leader>ff", ":Telescope find_files<cr>")
mapKey("<leader>fg", ":Telescope live_grep<cr>")
mapKey("<leader>fb", ":Telescope buffers<cr>")
mapKey("<leader>fh", ":Telescope help_tags<cr>")

-- nvim-lspconfig
mapKey("K", vim.lsp.buf.hover)
mapKey("gd", vim.lsp.buf.definition)
mapKey("<leader>ca", vim.lsp.buf.code_action)

-- Pane navigation
mapKey("<C-h>", "<C-w>h") -- Left
mapKey("<C-j>", "<C-w>j") -- Deft
mapKey("<C-k>", "<C-w>k") -- Up
mapKey("<C-l>", "<C-w>l") -- Right

-- Clear search hl
mapKey("<leader>h", ":nohlsearch<CR>")

-- Indentation
mapKey("<", "<gv", "v")
mapKey(">", ">gv", "v")
