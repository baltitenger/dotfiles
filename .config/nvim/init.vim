set expandtab shiftwidth=2 smarttab
set showmatch
set clipboard+=unnamed
set foldmethod=syntax
set foldlevelstart=99
set modeline
set mouse=a
set undofile

autocmd BufWritePre /tmp/* setlocal noundofile

if $TERM isnot# 'linux'
  set termguicolors
endif

highlight Folded ctermbg=0 guibg=Black

autocmd FileType python setlocal foldmethod=indent

autocmd FileType tex setlocal spell

:au BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis

nmap <Leader>/ :noh<CR>

call plug#begin('~/.config/nvim/plugged')
  Plug 'neomake/neomake'
  Plug 'arakashic/chromatica.nvim', { 'do': ':UpdateRemotePlugins'}
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'}
  Plug 'Shougo/neoinclude.vim'

  Plug 'lervag/vimtex'

  Plug 'lambdalisue/gina.vim'
  Plug 'lambdalisue/suda.vim'
  Plug 'mhinz/vim-signify'
  Plug 'aurieh/discord.nvim', { 'do': ':UpdateRemotePlugins'}
call plug#end()

"let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('smart_case', v:true)

autocmd FileType cpp let g:chromatica#enable_at_startup = 1

call neomake#configure#automake('nrwi', 500)

let g:tex_comment_nospell = 1
let g:tex_fold_enabled = 1
let g:vimtex_compiler_latexmk = {'build_dir': 'build'}
let g:vimtex_compiler_latexmk_engines = {'_': '-lualatex'}

command! W write suda://%
command! E edit suda://%
