# If not running interactively, don't do anything
[[ $- != *i* ]] && return

unset PROMPT_COMMAND
shopt -s globstar histappend lithist
tabs -2 2>/dev/null
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000

source /usr/share/git/git-prompt.sh 2>/dev/null &&
  GIT_PS1_COMPRESSSPARSESTATE=1 GIT_PS1_SHOWSTASHSTATE=1 \
  GIT_PS1_SHOWUPSTREAM=auto GIT_PS1_STATESEPARATOR=
SHORTPS1=$'\[\e]0;\u@\h:\W\a\]$(x=$?;((\j))&&echo -E \'\[\e[01;95m\]\j\';exit $((x==0?92:91)))\[\e[01;$?m\]\$\[\e[00m\] '
longps1() {
	PS1=$'\[\e[01;96m\][\[\e[92m\]\u\[\e[96m\]@\[\e[93m\]\h\[\e[96m\]:\[\e[94m\]\W'
	[ "`type -t __git_ps1`" == function ] && PS1+=$'$(__git_ps1 \'\[\e[96m\]#\[\e[00;32m\]%s\')'
	PS1+=$'\[\e[01;96m\]]'"$SHORTPS1"
}
shortps1() {
	PS1="$SHORTPS1"
}
longps1

precmd() {
	local cmd
	if [ "${BASH_COMMAND% *}" == fg ]; then
		local j=${BASH_COMMAND##fg*( )}
		cmd="$(tr '\0' ' ' <"/proc/$(jobs -p ${j:-%+})/cmdline")"
	else
		cmd="$BASH_COMMAND "
		while [[ "${cmd%% *}" == *=* ]]; do
			cmd="${cmd#* }"
		done
	fi
	printf $'\e]0;%s\a' "${cmd%% *}" >/dev/tty
}

alias config="git --git-dir=$HOME/.cfg --work-tree=$HOME"
alias gpgfix='gpg-connect-agent updatestartuptty /bye'
alias tmus="tmux new-session -As cmus 'tmux set status off && tmux set set-titles-string \\#{pane_title} && cmus'"
alias ytdl="yt-dlp --ignore-errors --output '%(title)s.%(ext)s' --no-mtime"
vmv() { nvim +"Renamer $1"; }

export CPPFLAGS CFLAGS CXXFLAGS LDFLAGS CC CXX
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

#eval `dircolors -b | sed 's/00;3/01;9/g'`
eval `dircolors -b`
alias ls='ls -F --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias tar='tar --totals=SIGUSR1'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias nethack='TERM=xterm nethack'
alias pass='PASSWORD_STORE_DIR=~/.local/share/pass pass'
alias tb='nc termbin.com 9999'
alias ix="curl -F 'f:1=<-' ix.io"
alias bp="curl -F 'raw=<-' https://bpa.st/curl"
alias man=$'LESS_TERMCAP_md="\e[01;91m" LESS_TERMCAP_me="\e[0m" LESS_TERMCAP_us="\e[01;32m" LESS_TERMCAP_ue="\e[0m" man'
alias sudo='sudo '
alias armexec='bwrap --unshare-all --hostname arm-chroot --bind ~/stuff/arm-chroot / --bind ~ ~ --proc /proc --dev /dev --tmpfs /tmp'
alias sshirssi='ssh minerva -t tmux -f ~/.irssi/tmux.conf new -An irssi irssi'

camurl='https://10.42.0.200:8080/video'
camstart() {
	adb shell -tt "su -c 'am start-activity com.pas.webcam/.Rolling'" </dev/null
}
camstop() {
	adb shell am force-stop com.pas.webcam
	sleep ${1:-0}
	adb shell input keyevent KEYCODE_POWER
}
camstream() {
	ffmpeg -i "$camurl" "$@" -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2 &&
		adb shell am force-stop com.pas.webcam
		#{ camstop 3 & disown $!; }
}

trap precmd DEBUG
