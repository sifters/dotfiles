# Dotfiles

## Format
Attempts to use [XDG (Cross-Desktop Group) Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) to manage dotfiles.

## Scripts
A handful of scripts are contained within the /scripts folder. These are intended to 
assist in system deployment or in setting up dotfiles.

## Nuances
### Minikube
Minikube creates a .minikube folder in $XDG_DATA_HOME/minikube (that is: /home/user/.local/share/minikube/.minikube/ ) and stores state there. The config.json file cannot be moved, only symlinked. Alternatively, environment variables can be used in lieu of the config file. These environment variables are located in the config/environment.d/minikube.conf file.
See [Minkube Dcoumentation](https://minikube.sigs.k8s.io/docs/handbook/config/).

