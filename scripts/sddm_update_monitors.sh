#!/bin/sh
SOURCE_TXT="~/.config/kwinoutputconfig.json"
DEST_DIR="/var/lib/sddm/.config/"
DEST_FILE="kwinoutputconfig.json"
DEST=$DEST_DIR$DEST_FILE
DEST_BAK="$DEST.bak"


# Help Information
usage() {
    echo "Usage: sudo $0 [OPTIONS]"
    echo ""
    echo "Copies $SOURCE_TXT to $DEST"
    echo "This script MUST be run with elevated privileges using sudo"
    echo "as it copies the desktop settings from the current user"
    echo "to a global configuration for sddm"
    echo ""
    echo "Options:"
    echo "  -h, --help      Display this help message"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            usage
            ;;
    esac
done

if [[ -z "$SUDO_USER" ]]; then
    echo "Error - Script is not run with sudo"
    echo ""
    usage
else
    if [[ -z "$SUDO_HOME" ]]; then
        SRC_HOME=$(getent passwd $SUDO_USER | cut -d: -f6) 
    else
        SRC_HOME=$SUDO_HOME
    fi
    SRC="$SRC_HOME/.config/kwinoutputconfig.json"
fi

cp $DEST $DEST_BAK
cp $SRC $DEST
chown $(stat -c %U:%G $DEST_DIR) $DEST_BAK
chown $(stat -c %U:%G $DEST_DIR) $DEST
