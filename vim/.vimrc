" ==========================================
" 1. General Editor Settings
" ==========================================
set nu                  " Show line numbers
set laststatus=2        " Always show the status line
set ruler               " Show the cursor position
set cursorline          " Highlight the current line
set title               " Set the terminal title to the filename
set mouse=a             " Enable mouse support in all modes
set clipboard=unnamed   " Use system clipboard (Universal macOS/Linux)

" ==========================================
" 2. Indentation & Tabs
" ==========================================
set expandtab           " Convert tabs to spaces
set ts=4                " Render TAB as 4 spaces
set sts=4               " Tab key inserts 4 spaces
set shiftwidth=4        " Indentation amount for >> and <<

" ==========================================
" 3. Search Settings
" ==========================================
set hlsearch            " Highlight search results
set incsearch           " Show search results as you type
set ignorecase          " Ignore case when searching...
set smartcase           " ...unless the search query contains uppercase

" ==========================================
" 4. Autocommands (Lifecycle)
" ==========================================
" Return to last edit position when opening files
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" ==========================================
" 5. Plugin Management (vim-plug)
" ==========================================
call plug#begin('~/.vim/plugged')

    Plug 'preservim/nerdtree'      " File explorer
    Plug 'osyo-manga/vim-anzu'     " Search status display
    Plug 'Yggdroot/indentLine'     " Vertical indentation guides
    Plug 'jiangmiao/auto-pairs'    " Automatic bracket pairing

call plug#end()

" ==========================================
" 6. Plugin Configurations & Keymaps
" ==========================================

" --- NERDTree ---
nnoremap <C-n> :NERDTreeToggle<CR>
" Auto-open NERDTree if Vim starts with no files specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Auto-close Vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" --- vim-anzu (Search Status) ---
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

