# Exports
export GOPATH=${XDG_DATA_HOME}/go
ZSH_CACHE=${XDG_CACHE_HOME}/zsh
ZSH_STATE=${XDG_STATE_HOME}/zsh
fpath=($ZSH_CACHE/zsh_completions $fpath)

# Create the folders if they do not exist
for d ($ZSH_CACHE $ZSH_STATE $ZSH_CACHE/zsh_completions); do
    [[ -d $d ]] || mkdir -p $d
done

# Configure History Settings
HISTFILE=${ZSH_STATE}/zsh_history
HISTFILESIZE=2000
HISTSIZE=2000
SAVEHIST=2000
setopt HIST_EXPIRE_DUPS_FIRST   # Delete duplicates first when rotating history file
setopt HIST_IGNORE_ALL_DUPS     # Ignore duplicates when writing history
setopt HIST_FIND_NO_DUPS        # When searching (CTRL+R); ignore duplicates
setopt SHARE_HISTORY            # Share history across sessions
setopt INC_APPEND_HISTORY       # Append each line to history file; do not wait to exit

# Additional shell options
setopt GLOBDOTS             # inlude hidden files


# Prompt Setup: Configure Powerline-Go
function powerline_precmd() {
    PS1="$($GOPATH/bin/powerline-go -mode $XDG_CONFIG_HOME/powerline-go/modes/test.json -theme $XDG_CONFIG_HOME/powerline-go/themes/nord.json -cwd-max-depth 3 -cwd-mode fancy -modules venv,host,ssh,cwd,perms,git,exit,root -error $? -jobs ${(%):-"%j"} )"
    PS1="$($GOPATH/bin/powerline-go -mode patched -theme $XDG_CONFIG_HOME/powerline-go/themes/nord.json -cwd-max-depth 3 -cwd-mode fancy -modules venv,host,ssh,cwd,perms,git,exit,root -error $? -jobs ${(%):-"%j"} )"
    set "?"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    install_powerline_precmd
fi
#############

# Initialize Shell Completion
autoload -U compinit; compinit -d $ZSH_CACHE/zcompdump-$ZSH_VERSION

# Additional imports
zdot_imports=(.zsh_functions .zsh_aliases)
for import in $zdot_imports; do
    if [[ -f $ZDOTDIR/$import ]]; then
        source $ZDOTDIR/$import
    fi
done
unset zdot_imports

