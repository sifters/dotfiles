# Specify XDG Variables - redundant because of environment.d
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Update PATH for local bin
export PATH=$HOME/.local/bin:$PATH

# ZShell
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Kubernetes
export KUBECONFIG=$XDG_CONFIG_HOME/kube/config
export KUBECACHEDIR=$XDG_CACHE_HOME/kube

# Python
export PYTHON_HISTORY=$XDG_STATE_HOME/python_history
export PYTHONPYCACHEPREFIX=$XDG_CACHE_HOME/python
export PYTHONUSERBASE=$XDG_DATA_HOME/python

# sqlite3
export SQLITE_HISTORY=$XDG_STATE_HOME/sqlite_history

# Load NVM - temporary
if [ -f $HOME/.profile ]; then
    source $HOME/.profile
fi
