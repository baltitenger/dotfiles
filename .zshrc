# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*' max-errors 3
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/baltazar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

function config {
  /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS='-R '
alias ls='ls -v --color=auto'
alias grep='grep --color=auto'
export PS1='%B%F{green}%n@%m%f:%F{blue}%1~%f%b%(#.#.$) '

export EDITOR=/usr/bin/nvim

autoload -Uz add-zsh-hook
function set-title-precmd() {
  echo -n "\e]2;$USER@$HOST:`basename "${PWD/#$HOME/~}"`\a"
}
add-zsh-hook precmd set-title-precmd

bindkey -v
bindkey '^R' history-incremental-search-backward

alias gpgupdatetty="gpg-connect-agent updatestartuptty /bye > /dev/null"
gpgupdatetty

alias ssh="gpgupdatetty && ssh"
alias scp="gpgupdatetty && scp"

bindkey ""      backward-delete-char
bindkey ""      backward-kill-word
bindkey ""      backward-kill-word
bindkey ""      backward-kill-line
bindkey "[3~"   delete-char
bindkey ""    self-insert-unmeta
bindkey "OM"    push-input
bindkey "[1;5D" backward-word
bindkey "[1;5C" forward-word
bindkey "OH"    beginning-of-line
bindkey "OF"    end-of-line

setopt INTERACTIVE_COMMENTS
setopt CORRECT
setopt APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_HUP
zmodload zsh/mathfunc
autoload -U zmv

yay() {
  command yay $@ && rehash
}

# Arduino-mk environmental variables
export ARDUINO_DIR=/usr/share/arduino
export ARDMK_DIR=/usr/share/arduino
export AVR_TOOLS_DIR=/usr
export ARDUINO_CORE_PATH=/usr/share/arduino/hardware/arduino/avr/cores/arduino
export BOARDS_TXT=/usr/share/arduino/hardware/arduino/avr/boards.txt
export ARDUINO_VAR_PATH=/usr/share/arduino/hardware/arduino/avr/variants
export BOOTLOADER_PARENT=/usr/share/arduino/hardware/arduino/avr/bootloaders
export AVRDUDE_CONF=/etc/avrdude.conf
export MONITOR_CMD=/home/baltazar/bin/monitor
export ARDUINO_QUIET=1
# ---

eval $(dircolors)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

alias tmus="tmux attach -t cmus"
