# Specify XDG Variables - redundant because of environment.d
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Update PATH for local bin
export PATH=$HOME/.local/bin:$PATH

# Load NVM - temporary
if [ -f $HOME/.profile ]; then
    source $HOME/.profile
fi
