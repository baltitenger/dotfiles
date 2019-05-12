export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
[ -z $SSH_AUTH_SOCK ] && export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
