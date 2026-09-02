local mapKey = require("utils.keyMapper").mapKey

-- Neotree toggle
mapKey("<leader>e", ":Neotree toggle<cr>")

-- Telescope
mapKey("<leader>ff", ":Telescope find_files<cr>")
mapKey("<leader>fg", ":Telescope live_grep<cr>")
mapKey("<leader>fb", ":Telescope buffers<cr>")
mapKey("<leader>fh", ":Telescope help_tags<cr>")

-- nvim-lspconfig
-- Bound to 'grr', not 'gr': Neovim already ships 'grn', 'gra', 'grr' and 'gri',
-- so a bare 'gr' stalls for 'timeoutlen' while waiting for the next key.
mapKey("K", vim.lsp.buf.hover)
mapKey("gd", vim.lsp.buf.definition)
mapKey("grr", function()
	require("telescope.builtin").lsp_references()
end)
mapKey("<leader>ca", vim.lsp.buf.code_action)

-- Pane navigation
mapKey("<C-h>", "<C-w>h") -- Left
mapKey("<C-j>", "<C-w>j") -- Down
mapKey("<C-k>", "<C-w>k") -- Up
mapKey("<C-l>", "<C-w>l") -- Right

-- Clear search hl
mapKey("<leader>h", ":nohlsearch<CR>")

-- Indentation
mapKey("<", "<gv", "v")
mapKey(">", ">gv", "v")

-- Vertical motion over wrapped lines
-- Move by screen row, since a bare j/k skips the whole logical line. The count
-- branch keeps 5j landing where the line numbers say.
mapKey("j", "v:count == 0 ? 'gj' : 'j'", { "n", "x" }, { expr = true })
mapKey("k", "v:count == 0 ? 'gk' : 'k'", { "n", "x" }, { expr = true })
