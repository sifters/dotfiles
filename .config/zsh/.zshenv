export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export PATH=$HOME/.local/bin:$PATH
export KUBECONFIG=$HOME/.kube/config
ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fpath=($ZDOTDIR/.zsh_completions $fpath)

# Load NVM - temporary
if [ -f $HOME/.profile ]; then
    source $HOME/.profile
fi
