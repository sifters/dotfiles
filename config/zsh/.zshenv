# Specify XDG Variables - redundant because of environment.d
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# For MacOS, .config/environment.d is not loaded by the system
# this function will loop through the directory and load
# the exports into ZSH, helping to ensure cross-compatibility

if [[ "$OSTYPE" == "darwin"* ]]; then
    local env_dir="$HOME/.config/environment.d"
    if [[ -d "$env_dir" ]]; then
        for env_file in "$env_dir"/*.conf(NOn); do
            set -a
            source "$env_file"
            set +a
        done
    fi
    unset env_dir env_file
fi


# Update PATH for local bin
export PATH=$HOME/.local/bin:$PATH

# Load NVM - temporary
if [ -f $HOME/.profile ]; then
    source $HOME/.profile
fi
