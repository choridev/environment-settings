set sts=4
set ts=4
set shiftwidth=4

set clipboard=unnamed " for macOS
set nu
set laststatus=2
set hlsearch
set ignorecase

set title

call plug#begin('~/.vim/plugged')

    Plug 'preservim/nerdtree'
	Plug 'osyo-manga/vim-anzu'

call plug#end()

nnoremap <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

