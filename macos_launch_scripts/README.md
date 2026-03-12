# macOS XDG Environment Sync

This project provides a mechanism to sync environment variables defined in `~/.config/environment.d/*.conf` to the macOS GUI environment (via `launchctl`). This ensures that applications launched via the Dock or Spotlight (like VS Code, Obsidian, or JetBrains IDEs) inherit the same XDG paths and variables as your terminal.

## Project Structure

* `macos-xdg-env-vars`: The Bash/Zsh script that parses config files and updates `launchctl`.
* `com.user.xdg-env-vars.plist`: The macOS Launch Agent configuration.
* `install.sh`: The automated installation script.

# Actions Summary

* Ensures the macos-xdg-env-vars are executable
* Symlinks macos-xdg-env-vars to $HOME/.local/bin
* Copies the com.user.xdg-env-vars.plist file to $HOME/Library/LaunchAgents/com.user.xdg-env-vars.plist
* Updates the com.user.xdg-env-vars.plist file to use the username of the user running the script
* Loads the plist file to ensure it is called on logon

## Installation

1. Navigate to this folder
2. **Run the installer**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
