export PATH="/home/baltazar/bin:/home/baltazar/.local/bin:$PATH"
gpg-connect-agent /bye
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
