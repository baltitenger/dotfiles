export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
[ -z $SSH_AUTH_SOCK ] && export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export ZDOTDIR="$HOME/.config/zsh"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
