func! myspacevim#before() abort
  let g:python_recommended_style = 0
  nmap <Leader>/ :noh<CR>
  set showmatch
  set clipboard+=unnamedplus
  set foldmethod=syntax

  let g:discord_fts_whitelist = ['asm', 'c', 'chef', 'coffee', 'cpp', 'crystal', 'cs', 'css', 'd', 'dart', 'diff', 'dockerfile', 'elixir', 'erlang', 'git', 'gitconfig', 'gitignore', 'go', 'haskell', 'html', 'javascript', 'json', 'jsx', 'kotlin', 'lang_c', 'lang_d', 'less', 'lua', 'markdown', 'neovim', 'nix', 'perl', 'php', 'python', 'ruby', 'rust', 'sass', 'scss', 'sh', 'swagger', 'tex', 'tf', 'vim', 'xml', 'yaml', 'java', 'txt']

  let g:vimtex_compiler_latexmk = {'build_dir' : 'build'}

  autocmd FileType python set foldmethod=indent

  "autocmd FileType arduino set syntax=arduino
  "autocmd FileType arduino set filetype=cpp

  autocmd FileType tex set spell

  autocmd FileType java set sw=4

  call neomake#configure#automake('nw', 750)
endf
