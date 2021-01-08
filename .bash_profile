export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
[ -z "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export EDITOR="`type -P nvim`"
. ~/.bashrc