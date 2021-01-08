if exists('current_compiler')
  finish
endif
let current_compiler = 'dotnet'

CompilerSet makeprg=dotnet\ msbuild\ -noLogo
CompilerSet errorformat=%f(%l\\,%c):\ %t%*\\i\ CS%n:\ %m\ [%*\\f]
CompilerSet errorformat+=%-G\ \ %*\\i\ ->\ %*\\f
