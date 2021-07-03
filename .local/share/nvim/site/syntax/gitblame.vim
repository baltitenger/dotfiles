" quit when a syntax file was already loaded
if exists('b:current_syntax') && b:current_syntax == 'gitblame'
  finish
endif

syn match gitblamePadding '^^*' contained
syn match gitblameHash    '^^*\x*' contains=gitblamePadding
syn match gitblameDate    '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d +\d\d\d\d$'
syn match gitblameNotcomm '^00000000 Not Committed Yet'

hi def link gitblamePadding Special
hi def link gitblameHash    Label
hi def link gitblameDate    Constant
hi def link gitblameNotcomm Comment

let b:current_syntax = 'gitblame'
