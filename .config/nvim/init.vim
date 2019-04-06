set expandtab shiftwidth=2 smarttab
set showmatch
set clipboard+=unnamed
set mouse=a
set foldmethod=syntax foldlevelstart=99
set modeline
set undofile
set scrolloff=3
autocmd BufWritePre /tmp/* setlocal noundofile

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

nmap <Leader>/ :noh<CR>

"Install Plug if not found
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
  Plug 'neomake/neomake'
  Plug 'arakashic/chromatica.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'Shougo/deoplete.nvim', { 'do': ':silent UpdateRemotePlugins'}
  Plug 'Shougo/neoinclude.vim'
  Plug 'lervag/vimtex'
  Plug 'lambdalisue/gina.vim'
  Plug 'lambdalisue/suda.vim'
  Plug 'mhinz/vim-signify'
  Plug 'majutsushi/tagbar', { 'on_cmd' : 'TagbarToggle' }
"  Plug 'aurieh/discord.nvim', { 'do': ':silent UpdateRemotePlugins'}
call plug#end()

silent! call neomake#configure#automake('nrwi', 500)

"let g:deoplete#enable_at_startup = 1
silent! call deoplete#custom#option('smart_case', v:true)

let g:chromatica#enable_at_startup = 1

let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1
let g:vimtex_compiler_latexmk = {'build_dir': 'build'}
let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}
autocmd FileType tex setlocal spell

autocmd FileType python setlocal foldmethod=indent
let g:python_recommended_style=0

command! W write suda://%
command! E edit suda://%
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
