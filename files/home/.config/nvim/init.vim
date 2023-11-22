" Configuration
syntax enable
filetype plugin indent on
set clipboard+=unnamedplus

" Appearance
set number
set cursorline
set termguicolors
colo PaperColor
" set background=dark
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE

" set background=light or dark depending on gnome system theme
let output = systemlist(['dconf', 'read', '/org/gnome/desktop/interface/color-scheme'])[0]
let isDark = (output == "'prefer-dark'")
if isDark
  set background=dark
else
  set background=light
endif

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
set statusline=%F
set foldmethod=syntax
set nofoldenable

" Customizations
let g:vim_markdown_folding_disabled = 1
let g:terraform_fmt_on_save = 1
let g:fzf_history_dir = '~/.tmp/fzf-history'

" Key mappings
nnoremap <silent> <C-p> :Files<CR>

" Custom Functions
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! GHDiffCommand()
    let temp_file = tempname()
    let gh_diff_cmd = 'gh pr diff > ' . temp_file
    execute '!'.gh_diff_cmd
    tabnew
    execute 'edit ' . temp_file
    setlocal filetype=diff
    setlocal readonly
endfunction

" Commands
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
command! -nargs=0 GHdiff call GHDiffCommand()

" Make Ag search everything
" Default options are --nogroup --column --color
let s:ag_options = '--hidden --skip-vcs-ignores --smart-case '
command! -bang -nargs=* Ag
      \ call fzf#vim#ag(
      \   <q-args>,
      \   s:ag_options,
      \  <bang>0 ? fzf#vim#with_preview('up:60%')
      \        : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0
      \ )

" Codeium settings
set statusline+=\|\{…\}%3{codeium#GetStatusString()}

let g:codeium_filetypes = {
  \ 'gitcommit': v:false,
  \ 'markdown': v:true,
  \ 'yaml': v:true
  \ }

" Copilot settings
let g:copilot_enabled = v:false

let g:copilot_filetypes = {
  \ 'gitcommit': v:true,
  \ 'markdown': v:true,
  \ 'yaml': v:true
  \ }

" ALE settings
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_use_neovim_diagnostics_api = 1
nmap <silent> [a <Plug>(ale_previous_wrap)
nmap <silent> ]a <Plug>(ale_next_wrap)
nmap <silent> [w <Plug>(ale_previous_wrap_warning)
nmap <silent> ]w <Plug>(ale_next_wrap_warning)
nmap <silent> [e <Plug>(ale_previous_wrap_error)
nmap <silent> ]e <Plug>(ale_next_wrap_error)

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

set statusline+=\|Lint:%{LinterStatus()}

" vim-ai settings
let g:vim_ai_chat = {
\  "options": {
\    "model": "gpt-4",
\    "temperature": 0.2,
\  },
\}
nnoremap <leader>a :AI<CR> " complete text on the current line or in visual selection
xnoremap <leader>a :AI<CR>
xnoremap <leader>c :AIChat<CR> " trigger chat
nnoremap <leader>c :AIChat<CR>
xnoremap <leader>n :AINewChat<CR> " trigger new chat
nnoremap <leader>n :AINewChat<CR>
nnoremap <leader>r :AIRedo<CR> " redo last AI command

" Autocommands
augroup LargeFile
  autocmd!
  autocmd BufReadPre *
        \ let f=getfsize(expand("<afile>"))
        \ | if f > 100000 || f == -2
        \ | let b:copilot_enabled = v:false
        \ | let b:codeium_enabled = v:false
        \ | endif
augroup END
autocmd VimResized * wincmd =
" Automatically reload files that were changed outside of Neovim
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
autocmd FileChangedShellPost * echo "File changed on disk. Buffer reloaded."
set updatetime=300
" Auto write buffers
set autowriteall
autocmd BufLeave * silent! wall
