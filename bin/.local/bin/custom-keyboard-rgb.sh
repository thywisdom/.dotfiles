#!/usr/bin/env bash
# =============================================================================
# custom-keyboard-rgb.sh — Simple toggle: flesh/1 on, off if already on
# =============================================================================

set -euo pipefail

readonly ALG_RGB_BIN="alg-rgb"
readonly STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/keyboard-rgb.state"

# ---------------------------------------------------------------------------
# State helpers
# ---------------------------------------------------------------------------
state_read() {
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

# ---------------------------------------------------------------------------
# Run alg-rgb — uses sg fallback if not yet in the alg-rgb group this session
# ---------------------------------------------------------------------------
run_alg_rgb() {
    local color="$1" brightness="${2:-}"
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

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
main() {
    command -v "$ALG_RGB_BIN" >/dev/null 2>&1 || {
        printf 'Error: %s not found. See https://github.com/24kaushik/alg-cli\n' "$ALG_RGB_BIN" >&2
        exit 1
    }

    local backlight
    state_read "backlight" backlight

    if [[ "$backlight" == "on" ]]; then
        run_alg_rgb off
        state_write "backlight" "off"
    else
        run_alg_rgb flesh 1
        state_write "backlight" "on"
    fi
}

main "$@"
