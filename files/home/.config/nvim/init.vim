" Configuration
syntax enable
filetype plugin indent on
set clipboard+=unnamedplus

" Appearance
set number
set cursorline
set termguicolors
colo PaperColor
set background=light
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE

" Indentation and tabs
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" File backup and undo
set backup
set backupdir=~/.tmp/backup/
set undofile
set undodir=~/.tmp/undo/
set dir=~/.tmp/swap/

" Search and navigation
set hlsearch
set incsearch
set mouse=a
set laststatus=2
set statusline+=%F
set foldmethod=syntax
set nofoldenable

" Customizations
let g:vim_markdown_folding_disabled = 1
let g:terraform_fmt_on_save = 1
let g:fzf_history_dir = '~/.tmp/fzf-history'

" Key mappings
nnoremap <silent> <C-p> :Files<CR>

" Functions
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

" Commands
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
command! -nargs=* -bang AgH call fzf#vim#ag(<q-args>, fzf#vim#with_preview() . '--hidden', <bang>0)

" Copilot settings
let g:copilot_filetypes = {
  \ 'gitcommit': v:true,
  \ 'markdown': v:true,
  \ 'yaml': v:true
  \ }

" Autocommands
augroup LargeFile
  autocmd!
  autocmd BufReadPre *
        \ let f=getfsize(expand("<afile>"))
        \ | if f > 100000 || f == -2
        \ | let b:copilot_enabled = v:false
        \ | endif
augroup END
