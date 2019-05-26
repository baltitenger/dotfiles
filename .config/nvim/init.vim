set expandtab shiftwidth=2 smarttab
set showmatch
set clipboard+=unnamed
set mouse=a
set foldmethod=syntax foldlevelstart=99
set modeline
set undofile
set scrolloff=3
set title
autocmd BufWritePre /tmp/* setlocal noundofile
set path+=**
let g:netrw_banner=0

"Enable fancy colors
if $TERM isnot# 'linux'
  set termguicolors
endif

highlight Folded ctermbg=0 guibg=Black
highlight Visual guibg =#403d3d

"Go to last position
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

autocmd BufReadPost *
  \ if filereadable("CMakeLists.txt")
  \ |   set makeprg=make\ -Cbuild\ -j$(nproc)
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

nnoremap <leader>f :ALEFix<CR>

"Install Plug if not found
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo '~/.local/share/nvim/site/autoload/plug.vim' --create-dirs
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
  Plug 'w0rp/ale'
  Plug 'arakashic/chromatica.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'Shougo/deoplete.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'Shougo/neoinclude.vim'
  Plug 'lervag/vimtex'
  Plug 'lambdalisue/gina.vim'
  Plug 'lambdalisue/suda.vim'
  Plug 'mhinz/vim-signify'
  Plug 'majutsushi/tagbar', { 'on_cmd' : 'TagbarToggle' }
  Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
  Plug 'vim-scripts/DoxygenToolkit.vim'
  Plug 'itchyny/screensaver.vim'
"  Plug 'aurieh/discord.nvim', { 'do': ':silent UpdateRemotePlugins'}
call plug#end()

let g:ale_fixers = {
\ 'cpp': [
\   'clang-format',
\ ],
\ 'html': [
\   'prettier',
\ ],
\}

"let g:deoplete#enable_at_startup = 1
silent! call deoplete#custom#option('smart_case', v:true)

let g:chromatica#enable_at_startup = 1
let g:chromatica#responsive_mode = 1

let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1
let g:vimtex_compiler_latexmk = {'build_dir': 'build'}
let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}
autocmd FileType tex setlocal spell

autocmd FileType python setlocal foldmethod=indent
let g:python_recommended_style=0

let g:load_doxygen_syntax=1

command! W write suda://%
command! E edit suda://%
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
