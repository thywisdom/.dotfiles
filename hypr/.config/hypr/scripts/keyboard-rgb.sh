#!/usr/bin/env bash
# =============================================================================
# keyboard-rgb.sh — Walker launcher plugin for Acer ALG keyboard RGB control
#
# FLOW:
#   Step 1 — Top-level menu:   Toggle On/Off | Set Color | Presets
#   Step 2 — Color picker:     (shown after "Set Color")
#   Step 3 — Intensity picker: (shown after selecting a color)
#
# STATE FILE stores last color + brightness so Toggle works correctly.
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly ALG_RGB_BIN="alg-rgb"

# XDG-compliant state persistence
readonly STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/keyboard-rgb.state"

# Default for the "Default" preset
readonly DEFAULT_COLOR="flesh"
readonly DEFAULT_BRIGHTNESS=1

# Nerd Font icons
readonly ICON_TOGGLE="󰌌"    # keyboard
readonly ICON_OFF="󰌐"       # keyboard-off
readonly ICON_COLOR="󰏘"     # palette
readonly ICON_BRIGHT="󰃠"    # brightness
readonly ICON_PRESET="󰛨"    # star / preset
readonly ICON_BACK="󰁍"      # back arrow

# Ordered color list (alg-rgb names)
readonly COLORS=(
  white
  red
  orange
  yellow
  lime
  "light-green"
  green
  "green-cyan"
  cyan
  "light-blue"
  blue
  violet
  magenta
  pink
  flesh
  "bluish-white"
)

# Human-readable labels
declare -A COLOR_LABELS=(
  ["white"]="White"
  ["red"]="Red"
  ["orange"]="Orange"
  ["yellow"]="Yellow"
  ["lime"]="Lime"
  ["light-green"]="Light Green"
  ["green"]="Green"
  ["green-cyan"]="Green Cyan"
  ["cyan"]="Cyan"
  ["light-blue"]="Light Blue"
  ["blue"]="Blue"
  ["violet"]="Violet"
  ["magenta"]="Magenta"
  ["pink"]="Pink"
  ["flesh"]="Flesh"
  ["bluish-white"]="Bluish White"
)

# One emoji/icon per color for the picker (visual cue without colour rendering)
declare -A COLOR_ICONS=(
  ["white"]="⬜"
  ["red"]="🔴"
  ["orange"]="🟠"
  ["yellow"]="🟡"
  ["lime"]="🥝"
  ["light-green"]="🍏"
  ["green"]="🟢"
  ["green-cyan"]="💠"
  ["cyan"]="🩵"
  ["light-blue"]="🧊"
  ["blue"]="🔵"
  ["violet"]="🟣"
  ["magenta"]="🟪"
  ["pink"]="🩷"
  ["flesh"]="🟤"
  ["bluish-white"]="❄️"
)

# =============================================================================
# STATE HELPERS
# =============================================================================

state_read() {
  # state_read <key> <nameref_var>
  local key="$1"
  local -n _ref="$2"
  _ref=""
  [[ -f "$STATE_FILE" ]] || return 0
  _ref=$(grep -m1 "^${key}=" "$STATE_FILE" 2>/dev/null | cut -d= -f2- || true)
}

state_write() {
  local key="$1" value="$2"
  mkdir -p "$(dirname "$STATE_FILE")"
  if [[ -f "$STATE_FILE" ]] && grep -q "^${key}=" "$STATE_FILE" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$STATE_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >> "$STATE_FILE"
  fi
}

# =============================================================================
# APPLY
# =============================================================================

# ---------------------------------------------------------------------------
# run_alg_rgb <color> [brightness]
#   Helper to invoke alg-rgb. If the current process's active groups do not yet
#   include 'alg-rgb', it dynamically executes via 'sg alg-rgb' to avoid permission
#   denied errors before a session logout/restart.
# ---------------------------------------------------------------------------
run_alg_rgb() {
  local color="$1"
  local brightness="${2:-}"

  if id -G -n | grep -q -w "alg-rgb"; then
    if [[ -n "$brightness" ]]; then
      "$ALG_RGB_BIN" "$color" "$brightness"
    else
      "$ALG_RGB_BIN" "$color"
    fi
  else
    if [[ -n "$brightness" ]]; then
      sg alg-rgb -c "$ALG_RGB_BIN \"$color\" \"$brightness\""
    else
      sg alg-rgb -c "$ALG_RGB_BIN \"$color\""
    fi
  fi
}

# apply_color <color> [brightness]
#   Calls alg-rgb via run_alg_rgb, persists state, sends desktop notification.
apply_color() {
  local color="$1"
  local brightness="${2:-}"
  local human="${COLOR_LABELS[$color]:-$color}"

  if [[ "$color" == "off" ]]; then
    run_alg_rgb off
    state_write "backlight" "off"
    notify-send -a "Keyboard RGB" -u low \
      "${ICON_OFF} Keyboard RGB" "Backlight off" -t 1500 2>/dev/null || true
    return
  fi

  if [[ -n "$brightness" ]]; then
    run_alg_rgb "$color" "$brightness"
    state_write "color"      "$color"
    state_write "brightness" "$brightness"
    state_write "backlight"  "on"
    notify-send -a "Keyboard RGB" -u low \
      "${ICON_TOGGLE} Keyboard RGB" "${human}  •  Brightness ${brightness}" \
      -t 1500 2>/dev/null || true
  else
    run_alg_rgb "$color"
    state_write "color"     "$color"
    state_write "backlight" "on"
    notify-send -a "Keyboard RGB" -u low \
      "${ICON_TOGGLE} Keyboard RGB" "${human}" \
      -t 1500 2>/dev/null || true
  fi
}


# =============================================================================
# DEPENDENCY CHECK
# =============================================================================

check_dependency() {
  if ! command -v "$ALG_RGB_BIN" > /dev/null 2>&1; then
    notify-send -a "Keyboard RGB" -u critical \
      "Missing dependency" \
      "alg-rgb not found. Please visit https://github.com/24kaushik/alg-cli to install it." 2>/dev/null || true
    printf 'Error: %s not found. Please visit https://github.com/24kaushik/alg-cli to install it.\n' "$ALG_RGB_BIN" >&2
    exit 1
  fi
}

# =============================================================================
# STEP 3 — INTENSITY PICKER
#   Called after the user picks a color.
#   Shows brightness 1–4 plus "No preference" (let alg-rgb use its default).
# =============================================================================

step_intensity() {
  local color="$1"
  local human="${COLOR_LABELS[$color]:-$color}"
  local icon="${COLOR_ICONS[$color]:-󰏘}"

  local chosen
  chosen=$(printf '%s\n' \
    "${ICON_BRIGHT} Brightness 1  — Dim" \
    "${ICON_BRIGHT} Brightness 2  — Low" \
    "${ICON_BRIGHT} Brightness 3  — Medium" \
    "${ICON_BRIGHT} Brightness 4  — Full" \
    "${ICON_BACK} Back" \
    | walker --dmenu \
        --placeholder "${icon} ${human} — pick intensity" \
        2>/dev/null
  ) || true

  [[ -z "$chosen" ]] && return 0

  case "$chosen" in
    *"Brightness 1"*) apply_color "$color" 1 ;;
    *"Brightness 2"*) apply_color "$color" 2 ;;
    *"Brightness 3"*) apply_color "$color" 3 ;;
    *"Brightness 4"*) apply_color "$color" 4 ;;
    *"Back"*)         step_color ;;
  esac
}

# =============================================================================
# STEP 2 — COLOR PICKER
#   Called after the user chooses "Set Color".
# =============================================================================

step_color() {
  # Build the color list with icons + labels
  local color_entries=()
  for color in "${COLORS[@]}"; do
    local icon="${COLOR_ICONS[$color]:-󰏘}"
    local human="${COLOR_LABELS[$color]:-$color}"
    color_entries+=("${icon}  ${human}")
  done
  color_entries+=("${ICON_BACK}  Back")

  local chosen
  chosen=$(printf '%s\n' "${color_entries[@]}" \
    | walker --dmenu \
        --placeholder "${ICON_COLOR} Pick a color…" \
        2>/dev/null
  ) || true

  [[ -z "$chosen" ]] && return 0

  # Handle back
  [[ "$chosen" == *"Back"* ]] && { step_main; return; }

  # Match chosen label back to alg-rgb color key
  for color in "${COLORS[@]}"; do
    local human="${COLOR_LABELS[$color]:-$color}"
    if [[ "$chosen" == *"${human}"* ]]; then
      step_intensity "$color"
      return
    fi
  done
}

# =============================================================================
# STEP 1 — MAIN MENU
# =============================================================================

step_main() {
  local backlight color brightness
  state_read "backlight"  backlight
  state_read "color"      color
  state_read "brightness" brightness

  # ── Build dynamic Toggle label ──────────────────────────────────────────
  local toggle_label toggle_action
  if [[ "$backlight" == "on" && -n "${color:-}" ]]; then
    local human="${COLOR_LABELS[$color]:-$color}"
    local dim=""
    [[ -n "$brightness" ]] && dim="  Brightness ${brightness}"
    toggle_label="${ICON_OFF}  Turn Off  (currently: ${human}${dim})"
    toggle_action="turn_off"
  elif [[ "$backlight" == "off" && -n "${color:-}" ]]; then
    local human="${COLOR_LABELS[$color]:-$color}"
    local dim=""
    [[ -n "$brightness" ]] && dim="  Brightness ${brightness}"
    toggle_label="${ICON_TOGGLE}  Turn On   (restore: ${human}${dim})"
    toggle_action="turn_on"
  else
    # No state yet — offer a basic on/off
    toggle_label="${ICON_TOGGLE}  Turn On   (default: White)"
    toggle_action="turn_on_default"
  fi

  # ── Menu entries ─────────────────────────────────────────────────────────
  local menu
  menu=$(printf '%s\n' \
    "$toggle_label" \
    "${ICON_COLOR}  Set Color…" \
    "${ICON_PRESET}  Default  (White • Brightness ${DEFAULT_BRIGHTNESS})" \
    "${ICON_BRIGHT}  Maximum Brightness" \
    "${ICON_BRIGHT}  Minimum Brightness  (Dim)" \
  )

  local chosen
  chosen=$(printf '%s\n' "$menu" \
    | walker --dmenu \
        --placeholder "${ICON_TOGGLE} Keyboard RGB" \
        2>/dev/null
  ) || true

  [[ -z "$chosen" ]] && return 0

  case "$chosen" in
    # ── Toggle ─────────────────────────────────────────────────────────────
    *"Turn Off"*)
      apply_color "off"
      ;;

    *"Turn On"*"restore"* | *"Turn On"*"currently"*)
      # Restore the previous color + brightness
      if [[ -n "${color:-}" ]]; then
        apply_color "$color" "${brightness:-}"
      else
        apply_color "$DEFAULT_COLOR" "$DEFAULT_BRIGHTNESS"
      fi
      ;;

    *"Turn On"*"default"*)
      apply_color "$DEFAULT_COLOR" "$DEFAULT_BRIGHTNESS"
      ;;

    # ── Color picker ────────────────────────────────────────────────────────
    *"Set Color"*)
      step_color
      ;;

    # ── Presets ─────────────────────────────────────────────────────────────
    *"Default"*)
      apply_color "$DEFAULT_COLOR" "$DEFAULT_BRIGHTNESS"
      ;;

    *"Maximum Brightness"*)
      local cur_color="${color:-$DEFAULT_COLOR}"
      apply_color "$cur_color" 4
      ;;

    *"Minimum Brightness"* | *"Dim"*)
      local cur_color="${color:-$DEFAULT_COLOR}"
      apply_color "$cur_color" 1
      ;;
  esac
}

# =============================================================================
# ENTRY POINT
# =============================================================================

main() {
  check_dependency

  if [[ "${1:-}" == "toggle" ]]; then
    local backlight color brightness
    state_read "backlight"  backlight
    state_read "color"      color
    state_read "brightness" brightness

    if [[ "$backlight" == "on" && -n "${color:-}" ]]; then
      apply_color "off"
    else
      if [[ -n "${color:-}" ]]; then
        apply_color "$color" "${brightness:-}"
      else
        apply_color "$DEFAULT_COLOR" "$DEFAULT_BRIGHTNESS"
      fi
    fi
    return
  fi

  step_main
}

main "$@"
