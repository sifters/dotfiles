#!/bin/sh

left_monitor="HDMI-A-1"

left_monitor_pos=$(kscreen-doctor --json | jq -r --arg monitor "$left_monitor" '.outputs[] | select(.name == $monitor) | .pos.x')
if [ "$left_monitor_pos" == "0" ]; then
    exit 0
fi

# Get monitor info as JSON and parse into array
readarray -t monitors < <(kscreen-doctor --json | jq -r '.outputs[] | "\(.pos.x):\(.size.width):\(.name)"' | sort -t: -k1 -n)

# Swap monitor X Positions
if [ ${#monitors[@]} -eq 2 ]; then
    # Parse first monitor (leftmost)
    IFS=':' read -r x1 width1 mon1 <<< "${monitors[0]}"
    # Parse second monitor (rightmost)
    IFS=':' read -r x2 width2 mon2 <<< "${monitors[1]}"

    # Swap positions
    kscreen-doctor output.$mon1.position.$width2,0 output.$mon2.position.0,0
fi
