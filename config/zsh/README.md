# ZSH Configurations
Z-Shell configurations require the .zshenv file to be placed in the user home directory.
This file is read first and sets up the variables to point ZSH to read from the appropriate
configuration files using the ZDOTDIR environment variables. 

Also contained within this file are the environment variables to set up XDG.

## Shell Completions
Shell completion scripts are added to the directory zsh_completions.  These must have
a prefix of an underscore.
While the contents can be loaded into the repository, it may be better to perform
scripted routines to run the completions.
