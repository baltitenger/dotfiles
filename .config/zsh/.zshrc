export BROWSER='/usr/bin/opera'
export CC='/usr/bin/clang'
export CXX='/usr/bin/clang++'
export EDITOR='/usr/bin/nvim'
export LESS='-R '
export LESSOPEN='| /usr/bin/src-hilite-lesspipe.sh %s'
export MANPAGER="/usr/bin/nvim -c 'set ft=man nomod nolist' -"
export PAGER='/usr/bin/less'
export PDFVIEWER='/usr/bin/okular'
eval $(dircolors)

alias ccat='source-highlight-esc.sh'
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias gpgfix='gpg-connect-agent updatestartuptty /bye >/dev/null'
alias grep='grep --color=auto'
alias ls='ls -v --color=auto'
alias make="make -sj$(nproc)"
alias pacdiff="sudo DIFFPROG='/usr/bin/nvim -d' DIFFSEARCHPATH='/boot /etc /usr' pacdiff"
alias sudo='sudo '
alias tmus='tmux attach -t cmus'
alias vi="$EDITOR"
alias ytdl="noglob youtube-dl --add-metadata --audio-format m4a --ignore-errors --output '%(title)s.%(ext)s'"

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*' max-errors 3
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

zstyle ':vcs_info:*' actionformats '%F{magenta}[%F{green}%b%F{yellow}|%F{red}%a%F{magenta}]%f'
zstyle ':vcs_info:*' enable git cvs svn
zstyle ':vcs_info:*' formats '%F{magenta}[%F{green}%b%F{magenta}]%f'
autoload -Uz vcs_info

function precmd() {
  # title
  echo -n "\e]2;$USER@$HOST:`basename "${PWD/#$HOME/~}"`\a"
  # prompt
  PS1='%B%F{%(!.red.green)}%n%F{cyan}@%F{yellow}%m%f:%F{blue}%1~%b'"$(vcs_info && echo ${vcs_info_msg_0_})"'%f%b%1(j.<%j>.)%B%F{%(?.green.red)}%(#.#.$)%f%b '
  PS2='%_['"$(( $(print -Pn $PS1 | sed 's/\[[0-9;]*m//g' | wc -c) - 2 ))"'C> '
}

# TODO
function yay() {
  command yay $@ && rehash
}

autoload -Uz zmv zcalc
zmodload zsh/mathfunc

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

HISTFILE="$ZDOTDIR/.histfile"
HISTSIZE=10000
SAVEHIST=10000
setopt appendHistory
setopt correct
setopt histFindNoDups
setopt histIgnoreDups
setopt histIgnoreSpace
setopt interactiveComments
setopt noHup
setopt notify

# plugins
repeat 1; do
  alias getantibody="curl -fL https://git.io/antibody | sh -s - -b $HOME/.local/bin"
  if which antibody >/dev/null; then; else
    echo "Installing antibody..."
    getantibody || break
  fi
  if [[ ! "$ZDOTDIR/.plugins.zsh" -nt "$ZDOTDIR/.plugins.txt" ]]; then
    echo "Updating plugins..."
    antibody bundle <"$ZDOTDIR/.plugins.txt" >"$ZDOTDIR/.plugins.zsh" || break
    zcompile "$ZDOTDIR/.plugins.zsh"
  fi
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
done

autoload -Uz compinit && compinit
if [[ ! "$ZDOTDIR/.zcompdump.zwc" -nt "$ZDOTDIR/.zcompdump" ]]; then
  zcompile "$ZDOTDIR/.zcompdump"
fi

if [[ ! "$ZDOTDIR/.zshrc.zwc" -nt "$ZDOTDIR/.zshrc" ]]; then
  zcompile "$ZDOTDIR/.zshrc"
fi
