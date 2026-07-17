#!/usr/bin/env bash

# Unified menu script using Walker

scripts_dir="/home/suman/.config/hypr/scripts"

# Define the options
options="Nightlight\nObsidian Sync\nProject Open"

# Show menu using walker in dmenu mode
choice=$(echo -e "$options" | uwsm app -- walker --dmenu)

case "$choice" in
    "Nightlight")
        exec "$scripts_dir/nightlight.sh"
        ;;
    "Obsidian Sync")
        exec "$scripts_dir/obsync.sh"
        ;;
    "Project Open")
        exec "$scripts_dir/project-open.sh"
        ;;
esac
