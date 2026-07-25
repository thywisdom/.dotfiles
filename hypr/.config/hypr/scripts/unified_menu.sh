#!/usr/bin/env bash
# unified_menu.sh — Walker dmenu for quick-access scripts

SCRIPTS_DIR="${HOME}/.config/hypr/scripts"
PKG_SCRIPT="${HOME}/.pkgmgmt/package.sh"
if [[ ! -x "$PKG_SCRIPT" ]]; then
  PKG_SCRIPT="${HOME}/dotfiles/pkgmgmt/.pkgmgmt/package.sh"
fi

open_in_terminal() {
  local cmd="$1"
  if command -v omarchy-default-terminal &>/dev/null; then
    exec uwsm app -- "$(omarchy-default-terminal)" -e bash -c "$cmd"
  elif command -v xdg-terminal-exec &>/dev/null; then
    exec uwsm app -- xdg-terminal-exec -e bash -c "$cmd"
  elif command -v foot &>/dev/null; then
    exec uwsm app -- foot -e bash -c "$cmd"
  elif command -v kitty &>/dev/null; then
    exec uwsm app -- kitty -e bash -c "$cmd"
  else
    exec uwsm app -- x-terminal-emulator -e bash -c "$cmd"
  fi
}

choice=$(printf 'Nightlight\nObsidian Sync\nProject Open\nKeyboard RGB\nIgnore Package\nShow Ignored Packages\n' | uwsm app -- walker --dmenu)

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
  "Ignore Package")
    open_in_terminal "$PKG_SCRIPT add-ignore"
    ;;
  "Show Ignored Packages")
    open_in_terminal "$PKG_SCRIPT show-ignore; echo; read -n 1 -s -r -p 'Press any key to close...'"
    ;;
esac
