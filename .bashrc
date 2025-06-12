# If not running interactively, don't do anything
[[ $- != *i* ]] && return

unset PROMPT_COMMAND
shopt -s globstar histappend lithist
# tabs -2 2>/dev/null
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000

source /usr/share/bash-complete-alias/complete_alias 2>/dev/null &&
	complete -F _complete_alias config ytdl ytmdl userctl

source /usr/share/git/git-prompt.sh 2>/dev/null &&
	GIT_PS1_COMPRESSSPARSESTATE=1 GIT_PS1_SHOWSTASHSTATE=1 \
	GIT_PS1_SHOWUPSTREAM=auto GIT_PS1_STATESEPARATOR= \
	GIT_PS1_DESCRIBE_STYLE=branch
SHORTPS1=$'\[\e]133;A\e\\\e]2;\u@\h:\W\e\]$(x=$?;((\j))&&echo -E \'\[\e[1;35m\]\j\';exit $((x==0?32:31)))\[\e[1;$?m\]\$\[\e[0m\] '
[ -n "$SWAYSOCK" ] && SHORTPS1=$'\[\e]7;file://$PWD\e\]'"$SHORTPS1"
longps1() {
	# before: \[\e[7m%\e[m\]$(printf "%$((COLUMNS-1))s")\r
	PS1=$'\[\e[1;36m\][\[\e[32m\]\u\[\e[36m\]@\[\e[33m\]\h\[\e[36m\]:\[\e[34m\]\W'
	[ "`type -t __git_ps1`" == function ] && PS1+=$'$(__git_ps1 \'\[\e[36m\]#\[\e[00;32m\]%s\')'
	PS1+=$'\[\e[1;36m\]]'"$SHORTPS1"
}
shortps1() {
	PS1="$SHORTPS1"
}
longps1

precmd() {
	local cmd
	if [ "${BASH_COMMAND% *}" == fg ]; then
		local j="${BASH_COMMAND##fg*( )}"
		cmd="$(tr '\0' ' ' <"/proc/$(jobs -p ${j:-%+} 2>/dev/null)/cmdline")"
	else
		cmd="$BASH_COMMAND"
		while read x rest <<<"$cmd" && [[ "$x" == *=* || "$x" == sudo ]]; do
			cmd="$rest"
		done
	fi
	cmd="${cmd#sudo }"
	printf $'\e]0;%s\a' "${cmd%% *}" >/dev/tty
}

alias config="git --git-dir=$HOME/.cfg --work-tree=$HOME"
alias gpgfix='gpg-connect-agent updatestartuptty /bye'
alias tmus="tmux new-session -As cmus 'tmux set status off && tmux set set-titles-string \\#{pane_title} && cmus'"
alias ytdl="yt-dlp --ignore-errors --output '%(title)s.%(ext)s' --no-mtime"
alias ytmdl="yt-dlp --ignore-errors --output '%(track_number)02d. %(track)s.%(ext)s' --no-mtime --embed-metadata"
vmv() { nvim +"Renamer $1"; }

export CPPFLAGS CFLAGS CXXFLAGS LDFLAGS CC CXX
envdbg() {
	CFLAGS='-Og -pipe -fno-plt -Wall -Wextra -Wno-unused-parameter -g'
	CXXFLAGS='-Og -pipe -fno-plt -Wall -Wextra -Wno-unused-parameter -Wp,-D_GLIBCXX_DEBUG -g -std=c++20'
	LDFLAGS='-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now'
}
envrel() {
	CFLAGS='-O2 -pipe -fno-plt -Wp,-D_FORTIFY_SOURCE=3 -Wall -Wextra -Wno-unused-parameter -g -flto=auto'
	CXXFLAGS='-O2 -pipe -fno-plt -Wp,-D_FORTIFY_SOURCE=3 -Wall -Wextra -Wno-unused-parameter -g -Wp,-D_GLIBCXX_ASSERTIONS -std=c++20 -flto=auto'
	LDFLAGS='-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -flto=auto'
}

eval `dircolors -b | sed 's/40;//g'`
alias ls='ls -F --color=auto --hyperlink=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias tar='tar --totals=SIGUSR1'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias nethack='TERM=xterm nethack'
alias pass='PASSWORD_STORE_DIR=~/.local/share/pass pass'
alias tb='nc termbin.com 9999'
alias ix="curl -F 'f:1=<-' ix.io"
alias bp="curl -F 'raw=<-' https://bpa.st/curl"
alias imgur="{ curl -sH 'Authorization: Client-ID 0bffa5b4ac8383c' -F 'image=<-' https://api.imgur.com/3/image | jq -r .data.link; }"
alias 0x0="curl -F'file=@-' http://0x0.st"
# alias man=$'LESS_TERMCAP_md="\e[01;91m" LESS_TERMCAP_me="\e[0m" LESS_TERMCAP_us="\e[01;32m" LESS_TERMCAP_ue="\e[0m" man'
alias man='LESS=Dd+r\$DuG GROFF_NO_SGR= man'
alias perldoc='LESS=Dd+r\$DuG GROFF_NO_SGR= perldoc -o man'
alias sudo='sudo '
alias dotnet='DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet'
# alias armexec="bwrap --unshare-ipc --unshare-pid --unshare-uts --unshare-cgroup --hostname arm-chroot \
# --bind ~/stuff/arm-chroot / --bind ~ ~ --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run \
# --ro-bind /usr/{,host/}bin --ro-bind /usr/{,host/}include --ro-bind /usr/{,host/}lib --ro-bind /usr/{,host/}share \
# --ro-bind /usr/lib/ld-linux-x86-64.so.2{,} --ro-bind /etc/resolv.conf /run/systemd/resolve/resolv.conf \
# --setenv LD_LIBRARY_PATH '/usr/host/\$LIB' --setenv PATH \"/usr/override/bin:/usr/host/bin:\$PATH\""
alias armexec='bwrap --unshare-ipc --unshare-pid --unshare-uts --unshare-cgroup --hostname arm-chroot \
--bind ~/stuff/arm-chroot / --bind ~ ~ --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run \
--ro-bind /etc/resolv.conf /run/systemd/resolve/resolv.conf --bind /mnt /mnt'
alias aarch64exec='bwrap --unshare-ipc --unshare-pid --unshare-uts --unshare-cgroup --hostname aarch64-chroot \
--bind ~/things/archlinuxarm/aarch64 / --bind ~ ~ --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run \
--ro-bind /etc/resolv.conf /run/systemd/resolve/resolv.conf --bind /mnt /mnt'
alias sshirssi='ssh minerva -t tmux -f ~/.irssi/tmux.conf new -As irssi irssi'
alias pacdiff='DIFFPROG=nvim\ -d pacdiff'
alias xfreerdp='xfreerdp /floatbar:sticky:off,show:always /workarea -decorations /drive:share,"$HOME/Downloads"'
alias wlfreerdp='wlfreerdp /size:"$(swaymsg -t get_tree | jq -r '\''..|select(.focused?).rect|"\(.width)x\(.height)"'\'')"'
alias ytmmix='mpv --vid=no --ytdl-raw-options=cookies-from-browser=chromium+gnomekeyring ytdl://RDTMAK5uy_kset8DisdE7LSD4TNjEVvrKRTmG7a56sY'
alias texdoc='LC_ALL="$LANG" texdoc'
alias userctl='systemctl --user'
# alias cmake='CMAKE_EXPORT_COMPILE_COMMANDS=ON PICO_SDK_PATH=~/stuff/pico-sdk PICO_EXTRAS_PATH=~/stuff/pico-extras FREERTOS_KERNEL_PATH=~/stuff/FreeRTOS-Kernel CMAKE_GENERATOR=Ninja cmake'
alias cmake='CMAKE_EXPORT_COMPILE_COMMANDS=ON PICO_SDK_PATH=~/stuff/pico-sdk PICO_EXTRAS_PATH=~/stuff/pico-extras CMAKE_GENERATOR=Ninja cmake'
alias make='NANOPB_DIR=~/stuff/nanopb make'
alias sage='LESS=-R sage'
info() { nvim -R -M +"Info $1 $2" +only; }

# [ "$XDG_SESSION_TYPE" = tty ] && alias sway='systemctl --user reset-failed; exec systemd-cat systemd-run --user --scope -u sway-session -E TERMINAL=foot -E QT_QPA_PLATFORMTHEME=kde -E XDG_CURRENT_DESKTOP=sway -E SDL_VIDEODRIVER=wayland -E _JAVA_AWT_WM_NONREPARENTING=1 -E VDPAU_DRIVER=va_gl -E WLR_SCENE_DISABLE_DIRECT_SCANOUT=1 sway'
if [ "$XDG_SESSION_TYPE" = tty ]; then
	sway() {
		systemctl --user reset-failed
		exec systemd-cat systemd-run --user --scope -u sway-session \
			-E GTK_THEME=Breeze:dark \
			-E QT_QPA_PLATFORMTHEME=kde \
			-E SDL_VIDEODRIVER=wayland,x11 \
			-E TERMINAL=foot \
			-E VDPAU_DRIVER=va_gl \
			-E WLR_RENDERER=vulkan \
			-E XDG_CURRENT_DESKTOP=sway \
			-E _JAVA_AWT_WM_NONREPARENTING=1 \
			sway "$@"
	}
	[ "$XDG_VTNR" = 1 ] && sway
fi

# camurl='http://192.168.11.175:8080/video'
camurl='http://192.168.185.232:8080/video'
camstart() {
	adb shell -tt "su -c 'am start-activity com.pas.webcam/.Rolling'" </dev/null
}
camstop() {
	adb shell am force-stop com.pas.webcam
	sleep ${1:-0}
	adb shell input keyevent KEYCODE_POWER
}
camstream() {
	filter=''
	while
		[ "$filter" ] && opt=(-vf "$filter") || opt=()
		ffmpeg -v error -i "$camurl" ${opt[@]} -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video4 </dev/null &
		read -e filter
	do
		kill $!
		wait $!
		history -s "$filter"
	done
	kill $!
	wait $!
		# adb shell am force-stop com.pas.webcam
		#{ camstop 3 & disown $!; }
}

trap precmd DEBUG
