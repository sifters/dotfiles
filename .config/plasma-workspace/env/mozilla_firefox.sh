#!/bin/sh

# Set up variables
MOZ_FF_PROFILE="default"
MOZ_FF_PATH="/mozilla/firefox/"

# Export the environment variables
# provide exception handling if XDG_* specifications have not yet been loaded
export XRE_PROFILE_PATH="${XDG_DATA_HOME:-$HOME/.local/share}$MOZ_FF_PATH$MOZ_FF_PROFILE"
export XRE_PROFILE_LOCAL_PATH="${XDG_CACHE_HOME:-$HOME/.cache}$MOZ_FF_PATH$MOZ_FF_PROFILE"

# Create directories if they do not exist to prevent errors when firefox launches
mkdir -p $XRE_PROFILE_PATH
mkdir -p $XRE_PROFILE_LOCAL_PATH
