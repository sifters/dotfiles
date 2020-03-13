# VIM configs

## Cloning This Repository
To clone the repository and all related packages, git should be run recursively
```
$ git clone --recursive https://github.com/sifters/.vim.git
```

## Packages
plugins are added as submodules to the .vim/pack/ folder

To add a new plugin:
```
$ git submodule add https://<git repository>.git .vim/pack/plugins/[start|opt]/<plugin_name>
```

Adding a plugin to the **start** folder will autoload it; whereas adding it to the **opt** folder will make it available to be loaded within vim

For example (assuming the command is run from the .vim/ folder):
```
$ git submodule add https://github.com/jmcantrell/vim-diffchanges.git pack/plugins/start/diffchanges/
$ git submodule add https://github.com/AndrewRadev/linediff.vim.git pack/plugins/start/linediff/
```
