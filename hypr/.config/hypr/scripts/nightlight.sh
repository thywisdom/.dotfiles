#!/bin/bash

# -------------------------------
# Config
# -------------------------------
ON_TEMP=3250
OFF_TEMP=6000

# -------------------------------
# Ensure hyprsunset is running
# -------------------------------
if ! pgrep -x hyprsunset >/dev/null; then
    setsid uwsm-app -- hyprsunset >/dev/null 2>&1 &
    sleep 1
fi

# -------------------------------
# Get current temperature
# -------------------------------
CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

# -------------------------------
# Toggle logic
# -------------------------------
if [[ "$CURRENT_TEMP" -le 4000 ]]; then
    # Already warm → switch to cool
    hyprctl hyprsunset temperature $OFF_TEMP
else
    # Currently cool → switch to warm
    hyprctl hyprsunset temperature $ON_TEMP
fi 