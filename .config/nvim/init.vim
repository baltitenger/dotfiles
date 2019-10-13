set expandtab shiftwidth=2 smarttab
set showmatch
set clipboard+=unnamed
set mouse=a
set foldmethod=syntax foldlevelstart=99
set modeline
set undofile
set scrolloff=3
set title
set ignorecase smartcase
autocmd BufWritePre /tmp/* setlocal noundofile
set path+=**
let g:netrw_banner=0
set autowrite
set makeprg=make\ -s\ -j$(nproc)
set linebreak

"Enable fancy colors
if $TERM isnot# 'linux'
  set termguicolors
endif

highlight Folded NONE ctermfg=14 guifg=Cyan
highlight Visual guibg =#403d3d
highlight ErrorMsg ctermbg=1 guibg=DarkRed
highlight Error ctermbg=1 guibg=DarkRed
highlight ErrorText guisp=Red gui=undercurl
highlight Warning ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
highlight WarningText guisp=Yellow gui=undercurl
highlight Info ctermfg=12 guifg=Cyan
highlight Pmenu ctermbg=6 guibg=DarkMagenta
highlight PmenuSel ctermfg=0 ctermbg=13 guifg=Blue guibg=Magenta

"Go to last position
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

autocmd BufReadPost *
  \ if filereadable("CMakeLists.txt")
  \ |   setlocal makeprg=make\ -s\ -Cbuild\ -j$(nproc)
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

"Install Plug if not found
if empty(glob("$HOME/.local/share/nvim/site/autoload/plug.vim"))
  silent !curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
  "Plug 'arakashic/chromatica.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'Shougo/deoplete.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
  Plug 'lervag/vimtex'
  Plug 'lambdalisue/gina.vim'
  Plug 'lambdalisue/suda.vim'
  Plug 'mhinz/vim-signify'
  Plug 'majutsushi/tagbar', { 'on_cmd' : 'TagbarToggle' }
  Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
  Plug 'vim-scripts/DoxygenToolkit.vim'
  Plug 'itchyny/screensaver.vim'
  Plug 'crucerucalin/qml.vim'
  Plug 'Shougo/neosnippet.vim'
  Plug 'Shougo/neosnippet-snippets'
call plug#end()

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
\     "name": "Error",
\     "texthl": "ErrorText",
\     "signText": "✖",
\     "signTexthl": "Error",
\     "virtualTexthl": "Error",
\   },
\   2: {
\     "name": "Warning",
\     "texthl": "WarningText",
\     "signText": "!",
\     "signTexthl": "Warning",
\     "virtualTexthl": "Warning",
\   },
\   3: {
\     "name": "Information",
\     "texthl": "Normal",
\     "signText": "ℹ",
\     "signTexthl": "Info",
\     "virtualTexthl": "Info",
\   },
\   4: {
\     "name": "Hint",
\     "texthl": "Normal",
\     "signText": "➤",
\     "signTexthl": "Info",
\     "virtualTexthl": "Info",
\   },
\ }

let g:deoplete#enable_at_startup = 1
silent! call deoplete#custom#option('smart_case', v:true)
call deoplete#custom#source('LanguageClient',
            \ 'min_pattern_length',
            \ 2)

"let g:chromatica#enable_at_startup = 1
"let g:chromatica#responsive_mode = 1

let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1
let g:vimtex_compiler_latexmk = {
      \ 'build_dir': 'build',
      \ }
let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}
autocmd FileType tex setlocal spell

autocmd FileType python setlocal foldmethod=indent
let g:python_recommended_style=0

let g:load_doxygen_syntax=1

command! W write suda://%
command! E edit suda://%
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
