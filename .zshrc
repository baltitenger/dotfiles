# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory extendedglob notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/baltazar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias less='less --RAW-CONTROL-CHARS'
export LS_OPTS='--color=auto'
alias ls='ls ${LS_OPTS}'
alias grep='grep --color=auto'
# export PS1='%B[%n@%m %1~]%(#.#.$)%b '
export PS1='%B%F{green}%n@%m%f:%F{blue}%1~%f%b%(#.#.$) '

export EDITOR=/usr/bin/vim

autoload -Uz add-zsh-hook
function set-title-precmd() {
    echo -n "\e]2;$USER@$HOST:`basename "${PWD/#$HOME/~}"`\a"
}
add-zsh-hook precmd set-title-precmd

bindkey -v
bindkey '^R' history-incremental-search-backward

alias fuck='sudo $(fc -ln -1)'
# alias ssh='/home/baltazar/bin/ssh.sh'

bindkey ""    backward-delete-char
bindkey ""    backward-kill-word
bindkey ""    backward-kill-word
bindkey ""    backward-kill-line
bindkey "[3~" delete-char
bindkey ""  self-insert-unmeta
bindkey "OM"  push-input

setopt INTERACTIVE_COMMENTS
setopt CORRECT
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
zmodload zsh/mathfunc

aurman() {
  command aurman $@ && rehash
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

