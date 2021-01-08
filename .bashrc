# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PROMPT_COMMAND='printf '\''\e]0;%s@%s:%s\a'\'' "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
source /usr/share/git/git-prompt.sh 2>/dev/null &&
  GIT_PS1_COMPRESSSPARSESTATE=1 GIT_PS1_SHOWSTASHSTATE=1 \
  GIT_PS1_SHOWUPSTREAM=auto GIT_PS1_STATESEPARATOR=
shopt -s globstar histappend lithist
tabs -2
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000
SHORTPS1=$'$(x=$?;((\j))&&echo -E \'\[\e[01;95m\]\j\';exit $((x==0?92:91)))\[\e[01;$?m\]\$\[\e[00m\] '
longps1() {
	PS1=$'\[\e[01;96m\][\[\e[92m\]\u\[\e[96m\]@\[\e[93m\]\h\[\e[96m\]:\[\e[94m\]\W'
	[ `type -t __git_ps1` == function ] && PS1+=$'$(__git_ps1 \'\[\e[96m\]#\[\e[00;32m\]%s\')'
	PS1+=$'\[\e[01;96m\]]'"$SHORTPS1"
}
shortps1() {
	PS1="$SHORTPS1"
}
longps1
eval `dircolors | sed 's/01;3/01;9/g'`
alias config="git --git-dir=$HOME/.cfg --work-tree=$HOME"
alias gpgfix='gpg-connect-agent updatestartuptty /bye'
alias tmus="tmux new-session -As cmus cmus"
alias ytdl="youtube-dl --ignore-errors --output '%(title)s.%(ext)s' --no-mtime"
vmv() { nvim +"Rename $1"; }
export CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
envdbg() {
	CPPFLAGS='-D_GLIBCXX_DEBUG'
	CFLAGS='-pipe -fno-plt -g -fvar-tracking-assignments -Wall -Wextra'
	CXXFLAGS='-pipe -fno-plt -g -fvar-tracking-assignments -Wall -Wextra -std=c++20'
	LDFLAGS='-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now'
}
envrel() {
	CPPFLAGS='-D_FORTIFY_SOURCE=2'
	CFLAGS='-O2 -pipe -fno-plt -Wall -Wextra'
	CXXFLAGS='-O2 -pipe -fno-plt -Wall -Wextra -std=c++20'
	LDFLAGS='-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now'
}

alias ls='ls -F --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias tar='tar --totals=SIGUSR1'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias pass='PASSWORD_STORE_DIR=~/.local/share/pass pass'
man() {
	LESS_TERMCAP_md=$'\e[01;91m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[01;32m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	command man "$@"
}
