export ARDMK="$HOME/stuff/arduino/arduino.mk"
export BROWSER='/usr/bin/opera'
export CC='/usr/bin/clang'
export CXX='/usr/bin/clang++'
export EDITOR='/usr/bin/vim'
export LESS='-R '
export LESSOPEN='| /usr/bin/src-hilite-lesspipe.sh %s'
export MANPAGER='/usr/bin/vim --not-a-term -c MANPAGER -'
export PAGER='/usr/bin/less'
export PASSWORD_STORE_DIR="$HOME/.local/share/pass"
export PDFVIEWER='/usr/bin/okular'
eval $(dircolors)

alias ccat='source-highlight-esc.sh'
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias getantibody="curl -fL https://git.io/antibody | sh -s - -b $HOME/.local/bin"
alias gpgfix='gpg-connect-agent updatestartuptty /bye >/dev/null'
alias grep='grep --color=auto'
alias ls='ls -v --color=auto'
alias make="make -j$(nproc)"
alias sudo='sudo --preserve-env=ZDOTDIR,EDITOR,XDG_CONFIG_HOME,XDG_DATA_HOME ' # gonna cause troubles for sure
alias tmus="tmux attach-session -t cmus 2>/dev/null || tmux -f '$XDG_CONFIG_HOME/cmus/tmux.conf' new-session -s cmus 'cmus'"
alias vi="$EDITOR"
alias xxd='hexdump -C'
alias ytdl="noglob youtube-dl --ignore-errors --output '%(title)s.%(ext)s'"

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*' max-errors 3
zstyle ':completion:*' menu select=long
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

zstyle ':vcs_info:*' actionformats '%F{magenta}[%F{green}%b%F{yellow}|%F{red}%a%F{magenta}]%f'
zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:*' check-for-staged-changes true
zstyle ':vcs_info:*' enable git hg svn
zstyle ':vcs_info:*' formats '%F{magenta}[%F{green}%b%F{magenta}]%f'
zstyle ':vcs_info:*+pre-get-data:*' hooks pre-get-data

bindkey -v
bindkey ''      backward-kill-word
bindkey ''      backward-kill-line
bindkey ''      backward-kill-word
bindkey ''    self-insert-unmeta
bindkey 'OF'    end-of-line
bindkey 'OH'    beginning-of-line
bindkey 'OM'    push-input
bindkey '[1;5C' forward-word
bindkey '[1;5D' backward-word
bindkey '[3~'   delete-char
bindkey '^R'      history-incremental-search-backward
bindkey ''      backward-delete-char

FORCE_RUN_VCS_INFO=1
PS1='%B%F{%(!.red.green)}%n%F{cyan}@%F{yellow}%m%f:%F{blue}%1~%b${vcs_info_msg_0_}%f%b%1(j.<%j>.)%B%F{%(?.green.red)}%(#.#.$)%f%b '
PS2='%_[$(( $(print -Pn $PS1 | sed '\''s/\[[0-9;]*m//g'\'' | wc -c) - 2 ))C> '
HISTFILE="$ZDOTDIR/.histfile"
HISTSIZE=10000
SAVEHIST=10000
setopt appendHistory
setopt correct
setopt histFindNoDups
setopt histIgnoreDups
setopt histIgnoreSpace
setopt interactiveComments
setopt notify
setopt promptsubst

autoload -Uz vcs_info zmv zcalc add-zsh-hook
zmodload zsh/mathfunc

+vi-pre-get-data() {
	[[ "$vcs" != git && "$vcs" != hg ]] && return
	if [[ -n $FORCE_RUN_VCS_INFO ]]; then
		FORCE_RUN_VCS_INFO=
		return
	fi
	ret=1
	case "$(fc -ln $(($HISTCMD-1)))" in
		git*)
			ret=0
			;;
		hg*)
			ret=0
			;;
	esac
}

prompt_precmd() {
	vcs_info
}
add-zsh-hook precmd prompt_precmd
set_title_precmd() {
	echo -n "\e]2;$USER@$HOST:`basename "${PWD/#$HOME/~}"`\a"
}
set_title_precmd
add-zsh-hook precmd set_title_precmd

prompt_chpwd() {
	FORCE_RUN_VCS_INFO=1
}
add-zsh-hook chpwd prompt_chpwd

if [[ "$TERM" == 'xterm-termite' && ( ! -f '/usr/share/terminfo/x/xterm-termite' ) && ( ! -f "$XDG_CONFIG_HOME/terminfo/x/xterm-termite" ) ]]; then
	echo 'Downloading terminfo for termite...'
	curl -fL 'https://raw.githubusercontent.com/thestinger/termite/master/termite.terminfo' | tic -xo"$XDG_CONFIG_HOME/terminfo" -
fi
export TERMINFO="$XDG_CONFIG_HOME/terminfo"

function plugins() {
	source "$ZDOTDIR/.plugins.zsh"

	autoload -Uz manydots-magic && manydots-magic

	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFA500'
	ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
	ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=cyan'
	ZSH_HIGHLIGHT_STYLES[path]='fg=green'
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFA500'

	HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
	HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='underline'
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	bindkey -M vicmd 'j' history-substring-search-down
	bindkey -M vicmd 'k' history-substring-search-up
}

if [[ "$SUDO_USER" && "$SUDO_USER" != "$USER" ]]; then
	HISTFILE="$HOME/.histfile"
	if [[ -f "$ZDOTDIR/.plugins.zsh" ]]; then
		plugins
	fi
	autoload -Uz compinit && compinit -C
else
	repeat 1; do
		if which antibody >/dev/null; then; else
			echo 'Installing antibody...'
			getantibody || break
		fi
		if [[ ! "$ZDOTDIR/.plugins.zsh" -nt "$ZDOTDIR/plugins.txt" ]]; then
			echo 'Updating plugins...'
			antibody bundle <"$ZDOTDIR/plugins.txt" >"$ZDOTDIR/.plugins.zsh" || break
			zcompile "$ZDOTDIR/.plugins.zsh"
		fi
		plugins
	done
	autoload -Uz compinit && compinit
	if [[ ! "$ZDOTDIR/.zcompdump.zwc" -nt "$ZDOTDIR/.zcompdump" ]]; then
		zcompile "$ZDOTDIR/.zcompdump"
	fi
	if [[ ! "$ZDOTDIR/.zshrc.zwc" -nt "$ZDOTDIR/.zshrc" ]]; then
		zcompile "$ZDOTDIR/.zshrc"
	fi
fi

unset plugins

# vim: ts=2 sw=0 noet
