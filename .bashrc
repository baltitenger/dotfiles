# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PROMPT_COMMAND='printf '\''\e]0;%s@%s:%s\a'\'' "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
source /usr/share/git/git-prompt.sh 2>/dev/null &&
  GIT_PS1_COMPRESSSPARSESTATE=1 GIT_PS1_SHOWSTASHSTATE=1 \
  GIT_PS1_SHOWUPSTREAM=auto GIT_PS1_STATESEPARATOR=
shopt -s globstar histappend lithist
tabs -2 2>/dev/null
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
vmv() { nvim +"Renamer $1"; }
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
alias tb='nc termbin.com 9999'
man() {
	LESS_TERMCAP_md=$'\e[01;91m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[01;32m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	command man "$@"
}

ix() {
	local opts='-n'
	local OPTIND
	while getopts ':hd:i:n:' x; do
		case $x in
			h) echo 'ix [-d ID] [-i ID] [-n N] [opts]'; return;;
			d) $echo curl $opts -X DELETE ix.io/$OPTARG; return;;
			i) opts="$opts -X PUT"; local id="$OPTARG";;
			n) opts="$opts -F read:1=$OPTARG";;
		esac
	done
	shift $(($OPTIND - 1))
	[ -t 0 ] && {
		local filename="$1"
		shift
		[ "$filename" ] && {
			curl $opts -F f:1=@"$filename" $* ix.io/$id
			return
		}
		echo '^C to cancel, ^D to send.'
	}
	curl $opts -F f:1='<-' $* ix.io/$id
}

texview() {
	feh -xR0 --keep-zoom-vp "https://tex.desnull.hu/$1.png" & disown $!
	echo "https://tex.desnull.hu/$1.png"
}

camstart() {
	adb shell -tt "su -c 'am start-activity com.pas.webcam/.Rolling'" </dev/null
}

camstream() {
	#ffmpeg -i https://192.168.11.139:8080/video "$@" -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2
	ffmpeg -i https://10.42.0.200:8080/video "$@" -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video2
}

camstop() {
	adb shell am force-stop com.pas.webcam
	adb shell input keyevent KEYCODE_POWER
}
