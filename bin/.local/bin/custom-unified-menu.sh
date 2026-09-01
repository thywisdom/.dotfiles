#!/usr/bin/env bash
# custom-unified-menu.sh — Omarchy quickshell menu for quick-access scripts

open_in_terminal() {
  local cmd="$1"
  local term
  term="$(omarchy-default-terminal 2>/dev/null || echo foot)"
  exec uwsm app -- "$term" --app-id custom-script -e bash -c "$cmd"
}

choice=$(printf 'Vault Sync\nProject Open\nKeyboard RGB\nSystem Cleanup\nPackage Manager\nBin Permissions\n' | omarchy-menu-select "Quick Access Scripts")

case "$choice" in
  # Nightlight option removed
  "Vault Sync")
    exec custom-vault-sync.sh
    ;;
  "Project Open")
    exec custom-project-open.sh
    ;;
  "Keyboard RGB")
    exec custom-keyboard-rgb.sh
    ;;
  "System Cleanup")
    # Launch in a terminal with app class "custom-script" so Hyprland floats it
    _term="$(omarchy-default-terminal 2>/dev/null || echo foot)"
    exec uwsm app -- "$_term" --app-id custom-script -e bash -c "custom-system-cleanup"
    ;;
  "Package Manager")
    open_in_terminal "custom-package-manage.sh"
    ;;
  "Bin Permissions")
    # Launch in a terminal with app class "custom-script" so Hyprland floats it
    _term="$(omarchy-default-terminal 2>/dev/null || echo foot)"
    exec uwsm app -- "$_term" --app-id custom-script -e bash -c "custom-bin-permissions.sh"
    ;;
esac
