set autowrite
set clipboard+=unnamed
set expandtab shiftwidth=2 smarttab
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

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
\ | wincmd p | diffthis

"Enable fancy colors
if $TERM isnot# 'linux'
  set termguicolors
endif

let g:netrw_banner=0
let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1
let g:python_recommended_style=0

autocmd FileType tex setlocal spell
autocmd FileType python setlocal foldmethod=indent
autocmd BufWritePre /tmp/* setlocal noundofile
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
\ |   exe "normal! g`\""
\ | endif

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

function! MyPlugins()
call plug#begin(stdpath('data').'/plugged')
  "Plug 'arakashic/chromatica.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'Shougo/deoplete.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'autozimu/LanguageClient-neovim', {
  \   'branch': 'next',
  \   'do': 'bash install.sh',
  \ }
  Plug 'lervag/vimtex'
  Plug 'lambdalisue/gina.vim'
  Plug 'lambdalisue/suda.vim'
  Plug 'mhinz/vim-signify'
  Plug 'majutsushi/tagbar', { 'on_cmd' : 'TagbarToggle' }
  Plug 'sakhnik/nvim-gdb', {
  \   'do': ':!./install.sh \| silent UpdateRemotePlugins',
  \ }
  Plug 'vim-scripts/DoxygenToolkit.vim'
  Plug 'itchyny/screensaver.vim'
  Plug 'crucerucalin/qml.vim'
  Plug 'Shougo/neosnippet.vim'
  Plug 'Shougo/neosnippet-snippets'
  Plug 'junegunn/vim-easy-align'
call plug#end()
endfunction " MyPlugins

function MyPluginSettings() " -------------------------------------------------

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:easy_align_delimiters = {
\   '/': {
\     'pattern':         '//\+\|/\*\|\*/',
\     'delimiter_align': 'l',
\     'ignore_groups':   ['!Comment']
\   },
\ }
autocmd FileType markdown imap <Bar> <Bar><Esc>m`gaip*<Bar>``A

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
"let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1

function! LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
    nnoremap <buffer> <silent> ge :call LanguageClient#explainErrorAtPoint()<CR>
    nnoremap <buffer> <silent> gh :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> gr :call LanguageClient#textDocument_rename()<CR>
    nnoremap <buffer> <silent> <leader>f :call LanguageClient_textDocument_formatting()<CR>
  endif
endfunction

autocmd FileType * call LC_maps()

let g:LanguageClient_serverCommands = {
  \ 'cpp':  ['clangd'],
  \ 'c':    ['clangd'],
  \ 'json': ['json-languageserver'],
  \ 'html': ['html-languageserver'],
  \ 'css':  ['css-languageserver'],
  \ }

let g:LanguageClient_diagnosticsDisplay = {
\   1: {
\     'name': 'Error',
\     'texthl': 'ErrorText',
\     'signText': '✖',
\     'signTexthl': 'Error',
\     'virtualTexthl': 'Error',
\   },
\   2: {
\     'name': 'Warning',
\     'texthl': 'WarningText',
\     'signText': '⚠',
\     'signTexthl': 'Warning',
\     'virtualTexthl': 'Warning',
\   },
\   3: {
\     'name': 'Information',
\     'texthl': 'Normal',
\     'signText': 'ℹ',
\     'signTexthl': 'Info',
\     'virtualTexthl': 'Info',
\   },
\   4: {
\     'name': 'Hint',
\     'texthl': 'Normal',
\     'signText': '➤',
\     'signTexthl': 'Info',
\     'virtualTexthl': 'Info',
\   },
\ }

let g:deoplete#enable_at_startup = 1
silent! call deoplete#custom#option('smart_case', v:true)
call deoplete#custom#source('LanguageClient',
\ 'min_pattern_length',
\ 2)

call deoplete#custom#var('omni',
\ 'input_patterns', {
\   'tex': g:vimtex#re#deoplete
\ })

call deoplete#custom#option('sources', {
\   'tex': ['omni'],
\   'cpp': ['LanguageClient', 'buffer'],
\ })

"let g:chromatica#enable_at_startup = 1
"let g:chromatica#responsive_mode = 1

let g:vimtex_compiler_latexmk = {'build_dir': 'build'}
let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}
let g:vimtex_view_general_viewer = 'llpp.inotify'
autocmd FileType tex inoremap <expr> <buffer> `` vimtex#imaps#wrap_math("``", '`')

let g:load_doxygen_syntax=1

command! W write suda://%
command! E edit suda://%

endfunction " MyPluginSettings ------------------------------------------------

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

"Install Plug if not found
if empty(glob(stdpath('data').'/site/autoload/plug.vim'))
  if $SUDO_USER == ''
    function! InitPlugins(jobId, exitCode, eventType)
      if a:exitCode != 0
        echoerr 'Failed to download vim-plug.'
      else
        call MyPlugins() | PlugInstall --sync | call MyPluginSettings()
      endif
    endfunction
    let jobid = jobstart(['/usr/bin/curl', '--create-dirs',
    \   '-fLo', stdpath('data').'/site/autoload/plug.vim',
    \   'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    \ ], {
    \   'on_exit': 'InitPlugins',
    \ })
    if jobid > 0
      echomsg 'Downloading vim-plug...'
    else
      echoerr 'Curl not found.'
    endif
  endif
else
  call MyPlugins()
  call MyPluginSettings()
endif
