#!/usr/bin/env bash
# unified_menu.sh — Walker dmenu for quick-access scripts

SCRIPTS_DIR="${HOME}/.config/hypr/scripts"

choice=$(printf 'Nightlight\nObsidian Sync\nProject Open\nKeyboard RGB\n' | uwsm app -- walker --dmenu)

case "$choice" in
  "Nightlight")
    exec "$SCRIPTS_DIR/nightlight.sh"
    ;;
  "Obsidian Sync")
    exec "$SCRIPTS_DIR/obsync.sh"
    ;;
  "Project Open")
    exec "$SCRIPTS_DIR/project-open.sh"
    ;;
  "Keyboard RGB")
    exec "$SCRIPTS_DIR/keyboard-rgb.sh"
    ;;
esac
