#!/usr/bin/env bash
# unified_menu.sh — Omarchy quickshell menu for quick-access scripts

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

choice=$(printf 'Vault Sync\nProject Open\nKeyboard RGB\nIgnore Package\nShow Ignored Packages\nBin Permissions\n' | omarchy-menu-select "Quick Access Scripts")

case "$choice" in
  # Nightlight option removed
  "Vault Sync")
    exec "${SCRIPTS_DIR}/vault-sync.sh"
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
  "Bin Permissions")
    # Launch in a terminal with app class "user-script" so Hyprland floats it
    _term="$(omarchy-default-terminal 2>/dev/null || echo foot)"
    exec uwsm app -- "$_term" --app-id user-script -e bash -c "${HOME}/.config/hypr/scripts/bin-permissions.sh"
    ;;
esac
