return {
  {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require('telescope').setup({
        extensions = {
          ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          }

          }
        }
      })
      require("telescope").load_extension("ui-select")
    end
  }
}
