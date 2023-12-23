# VIM configs

## Requirements
This repository uses unicode characters that are in reference to [NerdFonts](https://github.com/ryanoasis/nerd-fonts).

YAML linting is configured to use [yamllint](https://github.com/adrienverge/yamllint).


## Cloning This Repository
To clone the repository and all related packages, git should be run recursively
```
$ git clone --recursive https://github.com/sifters/.vim.git
```

Submodules may have to be initialized and updated following the initial clone
```
$ git submodule update --init --recursive
$ git submodule update --init --recursive --remote --merge
```

## Packages
plugins are added as submodules to the .vim/pack/ folder

To add a new plugin:
```
$ git submodule add https://<git repository>.git pack/plugins/[start|opt]/<plugin_name>
```

Following module additions, rebuilding the help tags inside of vim is needed.  
This will probably generate an error, but should be fine.
In Vim:
```
: helptags ALL
```

Adding a plugin to the **start** folder will autoload it; whereas adding it to the **opt** folder will make it available to be loaded within vim

For example (assuming the command is run from the .vim/ folder):
```
$ git submodule add https://github.com/jmcantrell/vim-diffchanges.git pack/plugins/start/diffchanges/
$ git submodule add https://github.com/AndrewRadev/linediff.vim.git pack/plugins/start/linediff/
```

To update submodules:
```
$ git submodule update --recursive --remote
```
