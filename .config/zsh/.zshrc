export  GOPATH=~/go
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

alias ll='ls -lah --color'

if [[ -d $ZDOSTDIR/.zsh_functions ]]; then
    source $ZDOTDIR/.zsh_functions
fi
