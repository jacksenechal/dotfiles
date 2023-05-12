call plug#begin('~/.vim/plugged')
Plug 'vim-scripts/candycode.vim'
Plug 'endel/vim-github-colorscheme'
Plug 'NLKNguyen/papercolor-theme'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'alvan/vim-closetag'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'hashivim/vim-terraform'
Plug 'hashivim/vim-packer'
Plug 'hashivim/vim-vaultproject'
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
set laststatus=2
set statusline+=%F
set foldmethod=syntax
set nofoldenable
let g:fzf_history_dir='~/.tmp/fzf-history'
let g:terraform_fmt_on_save=1
set background=dark
colo PaperColor
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE
nnoremap <silent> <C-p> :Files<cr>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
command! -nargs=* -bang AgH call fzf#vim#ag(<q-args>, fzf#vim#with_preview() . '--hidden', <bang>0)
