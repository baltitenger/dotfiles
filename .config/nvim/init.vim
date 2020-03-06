set autowrite
set clipboard+=unnamed
set shiftwidth=2 tabstop=2
set foldmethod=syntax foldlevelstart=99
set ignorecase smartcase
set linebreak
set makeprg=make\ -s\ -j$(nproc)
set modeline
set mouse=a
set path+=**
set scrolloff=3
set showmatch
set title
set undofile
set updatetime=300
set keymap=magyar iminsert=0
set diffopt+=iwhite
set list listchars=tab:\ \ 

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
\ | wincmd p | diffthis

"Enable fancy colors
if $TERM isnot# 'linux'
  set termguicolors
endif

let g:man_hardwrap = 1
let g:netrw_banner = 0
let g:python_recommended_style = 0
let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1

autocmd FileType tex setlocal spell
autocmd FileType python setlocal foldmethod=indent
autocmd BufWritePre /tmp/* setlocal noundofile
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line('$') && &ft !~# 'commit'
\|  exe 'normal! g`"'
\|endif

nmap <Leader>/ :noh<CR>
nmap Y y$

tnoremap <Esc> <C-\><C-n>
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

highlight Error       guibg=DarkRed     ctermbg=1
highlight ErrorMsg    guibg=DarkRed     ctermbg=1
highlight ErrorText   guisp=Red         gui=undercurl
highlight Folded      NONE              guifg=Cyan    ctermfg=14
highlight Info        guifg=Cyan        ctermfg=12
highlight Pmenu       guibg=DarkMagenta ctermbg=6
highlight PmenuSel    guifg=Blue        guibg=Magenta ctermfg=0 ctermbg=13
highlight SpellBad    guisp=Red         gui=undercurl
highlight SpellCap    guisp=Magenta     gui=undercurl
highlight SpellRare   guisp=Yellow      gui=undercurl
highlight Visual      guibg=#403d3d
highlight Warning     guifg=Blue        guibg=Yellow  ctermfg=0 ctermbg=11
highlight WarningText guisp=Yellow      gui=undercurl
highlight manUnderline guifg=Green      ctermfg=2
highlight link Whitespace NONE

let g:haveNode = executable('npm') || executable('yarn')
let g:haveLatex = executable('latexmk')
let g:haveGdb = executable('gdb')
let g:haveCtags = executable('ctags')

function! s:MyPlugins()
call plug#begin(stdpath('data').'/plugged')
if g:haveNode
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
if g:haveLatex
  Plug 'lervag/vimtex'
endif
if g:haveCtags
  Plug 'majutsushi/tagbar', { 'on_cmd' : 'TagbarToggle' }
endif
  Plug 'junegunn/vim-easy-align'
call plug#end()
if g:haveGdb
  packadd termdebug
endif
endfunction

function s:MyPluginSettings()
if g:haveNode
  " coc:
  nmap <silent> gd <Plug>(coc-definition)
  "nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  " coc-snippets:
  let g:coc_snippet_next = '<c-j>'
  let g:coc_snippet_prev = '<c-k>'
endif
if g:haveLatex
  " vimtex:
  let g:vimtex_compiler_latexmk = {'build_dir': 'build'}
  let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}
  if executable('llpp.inotify')
    let g:vimtex_view_general_viewer = 'llpp.inotify'
  endif
  autocmd FileType tex inoremap <expr> <buffer> `` vimtex#imaps#wrap_math("``", '`')
endif
  " EasyAlign:
  xmap ga <Plug>(EasyAlign)
  nmap ga <Plug>(EasyAlign)
  let g:easy_align_delimiters = {
  \   '/': {
  \     'pattern':         '//\+\|/\*\|\ \*',
  \     'delimiter_align': 'l',
  \     'ignore_groups':   ['!Comment'],
  \   },
  \   '\': {
  \     'pattern':         '\\',
  \     'indentation':     'keep',
  \     'left_margin':     1,
  \     'delimiter_align': 'center',
  \     'ignore_groups':   ['String', 'Comment'],
  \   },
  \ }
  autocmd FileType markdown imap <buffer> <Bar> <Bar><Esc>m`gaip*<Bar>``A
endfunction

"Install Plug if not found
if empty(glob(stdpath('data').'/site/autoload/plug.vim'))
  function! s:PlugInit(jobId, exitCode, eventType)
    if a:exitCode != 0
      echoerr 'Failed to download vim-plug.'
    else
      call <SID>MyPlugins()
      PlugInstall --sync
      call <SID>MyPluginSettings()
    endif
  endfunction
  function! s:PlugInstall()
    let jobid = jobstart(['/usr/bin/curl', '--create-dirs',
    \   '-fLo', stdpath('data').'/site/autoload/plug.vim',
    \   'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    \ ], {
    \   'on_exit': function('<SID>PlugInit'),
    \ })
    if jobid > 0
      echomsg 'Downloading vim-plug...'
    else
      echoerr 'Curl not found.'
    endif
  endfunction
  command! Plugins call <SID>PlugInstall()
else
  call <SID>MyPlugins()
  call <SID>MyPluginSettings()
endif
