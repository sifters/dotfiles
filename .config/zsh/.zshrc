# Exports
export  GOPATH=~/go
ZSH_CACHE=${XDG_CACHE_HOME}/zsh
ZSH_STATE=${XDG_STATE_HOME}/zsh
fpath=($ZSH_CACHE/zsh_completions $fpath)

for d ($ZSH_CACHE $ZSH_STATE $ZSH_CACHE/zsh_completions); do
    [[ -d $d ]] || mkdir -p $d
done

# Configure History Settings
HISTFILE=${ZSH_STATE}/zsh_history
HISTFILESIZE=2000
HISTSIZE=2000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY


# Configure Powerline-Go
function powerline_precmd() {
    PS1="$($GOPATH/bin/powerline-go -error $? -jobs ${${(%):%j}:-0})"
    PS1="$($GOPATH/bin/powerline-go -theme gruvbox -cwd-max-depth 2 -modules venv,host,ssh,cwd,perms,git,exit,root)"
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

# Initialize Shell Completion
autoload -U compinit; compinit -d $ZSH_CACHE/zcompdump-$ZSH_VERSION

# Additional import
if [[ -f $ZDOTDIR/.zsh_functions ]]; then
    source $ZDOTDIR/.zsh_functions
fi

if [[ -f $ZDOTDIR/.zsh_aliases ]]; then
    source $ZDOTDIR/.zsh_aliases
fi

