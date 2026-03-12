#!/bin/bash

# Define filenames based on your repo
REPO_PLIST="com.user.xdg-env-vars.plist"
REPO_SCRIPT="macos-xdg-env-vars"

# Define destination paths
DEST_PLIST="$HOME/Library/LaunchAgents/com.user.xdg-env-vars.plist"
BIN_DIR="$HOME/.local/bin"
DEST_SCRIPT="$BIN_DIR/macos-xdg-env-vars"

echo "Starting installation of macOS XDG Environment Sync..."

# 1. Ensure directories exist
mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$BIN_DIR"

# 2. Symlink the script to ~/.local/bin
if [[ -f "$REPO_SCRIPT" ]]; then
    # Ensure the source script is executable
    chmod 755 "$REPO_SCRIPT"

    # Get the absolute path of the script in the repo for the symlink
    FULL_REPO_SCRIPT_PATH="$(pwd)/$REPO_SCRIPT"
    
    ln -sf "$FULL_REPO_SCRIPT_PATH" "$DEST_SCRIPT"
    echo "Confirmed: Symlinked $REPO_SCRIPT -> $DEST_SCRIPT"
else
    echo "Error: $REPO_SCRIPT not found in current directory."
    exit 1
fi

# 3. Handle the plist
if [[ -f "$REPO_PLIST" ]]; then
    # Copy the plist to avoid modifying the version in the repo via sed
    cp "$REPO_PLIST" "$DEST_PLIST"
    
    CURRENT_USER=$(whoami)
    sed -i '' "s/YOUR_USERNAME/$CURRENT_USER/g" "$DEST_PLIST"
    echo "Confirmed: Updated $DEST_PLIST with username: $CURRENT_USER"
else
    echo "Error: $REPO_PLIST not found in current directory."
    exit 1
fi

# 4. Load the agent
# Unload first to ensure a fresh start if already exists
launchctl unload "$DEST_PLIST" 2>/dev/null
launchctl load "$DEST_PLIST"

echo "Installation complete. Your XDG variables are now synced for GUI apps."

# 5. Final verification
echo "Verifying agent status..."
if launchctl list | grep -q "com.user.xdg-env-vars"; then
    echo "Confirmed: Agent 'com.user.xdg-env-vars' is loaded."
else
    echo "Warning: Agent does not appear to be loaded. You may need to check the plist syntax."
fi

echo "Installation complete. Your XDG variables are now synced for GUI apps."
