if exists('current_compiler')
  finish
endif
let current_compiler = 'markdown'

CompilerSet makeprg=mkd2html
let &makeprg .= ' -css markdown.css'
let &makeprg .= ' <'.shellescape(expand('%')).' >'.shellescape(substitute(expand('%'), '^\(.*/\)\?\([^/]*\)\(.md\)$', '\1build/\2.html', ''))
