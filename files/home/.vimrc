call plug#begin('~/.vim/plugged')
Plug 'vim-scripts/candycode.vim'
Plug 'tpope/vim-commentary'
Plug 'alvan/vim-closetag'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
call plug#end()
syntax on
filetype plugin indent on
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab 
set number
set dir=~/.tmp/swap
set backup
set backupdir=~/.tmp/backup
set undofile
set undodir=~/.tmp/undo/
set hlsearch
set mouse=a
let g:fzf_history_dir='~/.tmp/fzf-history'
" colo candycode
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE
nnoremap <silent> <C-p> :Files<cr>
