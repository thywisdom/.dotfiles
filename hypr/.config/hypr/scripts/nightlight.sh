#!/bin/bash
# nightlight.sh — Toggle hyprsunset colour temperature (warm ↔ cool)

# ---------------------
# Config
# ---------------------
ON_TEMP=3250   # warm (night mode)
OFF_TEMP=6000  # cool (day mode)

# ---------------------
# Ensure hyprsunset is running
# ---------------------
if ! pgrep -x hyprsunset >/dev/null; then
  setsid uwsm-app -- hyprsunset >/dev/null 2>&1 &
  sleep 1
fi

# ---------------------
# Get current temperature
# ---------------------
CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

# ---------------------
# Toggle logic
# ---------------------
if [[ "$CURRENT_TEMP" -le 4000 ]]; then
  # Already warm → switch to cool (day mode)
  hyprctl hyprsunset temperature $OFF_TEMP
else
  # Currently cool → switch to warm (night mode)
  hyprctl hyprsunset temperature $ON_TEMP
fi