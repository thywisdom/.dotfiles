#!/usr/bin/env bash
# =============================================================================
# package.sh — Dotfiles package management utility
# =============================================================================
# Manages packages and pacman configuration from the dotfiles repository.
# The only permanent /etc/ modifications this script makes are:
#   1. Symlink: /etc/pacman.d/dotfiles-ignore.conf → this repo's ignore.conf
#   2. One Include line inside [options] in /etc/pacman.conf
#
# Everything else (IgnorePkg, NoUpgrade, etc.) lives in packages/pacman.d/ignore.conf
# and is symlinked — no further /etc/ edits are needed after initial setup.
#
# Stow-safe: this script lives inside pkgmgmt/.pkgmgmt/ and can be run:
#   • Directly:  ~/dotfiles/pkgmgmt/.pkgmgmt/package.sh
#   • If stowed: ~/.pkgmgmt/package.sh
#   readlink -f resolves symlinks back to the real file in dotfiles, so all
#   data paths work identically in both cases.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths — always anchor to this script's real (non-symlink) location
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Data paths — all siblings of this script under .pkgmgmt/
PACMAN_CONF="/etc/pacman.conf"
PACMAN_D_DIR="/etc/pacman.d"
SYMLINK_NAME="dotfiles-ignore.conf"
SYMLINK_PATH="$PACMAN_D_DIR/$SYMLINK_NAME"
IGNORE_CONF_SOURCE="$SCRIPT_DIR/packages/pacman.d/ignore.conf"
INCLUDE_LINE="Include = $SYMLINK_PATH"

PACMAN_TXT="$SCRIPT_DIR/packages/pacman.txt"
AUR_TXT="$SCRIPT_DIR/packages/aur.txt"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; RESET=''
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { echo -e "${CYAN}  →${RESET} $*"; }
success() { echo -e "${GREEN}  ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET} $*"; }
error()   { echo -e "${RED}  ✗${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }
die()     { error "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Prerequisite check
# ---------------------------------------------------------------------------
check_source_file() {
    [[ -f "$IGNORE_CONF_SOURCE" ]] || \
        die "Source file not found: $IGNORE_CONF_SOURCE\nIs the dotfiles repo intact?"
}

require_sudo() {
    if ! sudo -n true 2>/dev/null; then
        info "This step requires sudo. You may be prompted for your password."
    fi
}

# ---------------------------------------------------------------------------
# Verify — read-only, no side effects
# ---------------------------------------------------------------------------
cmd_verify() {
    header "Verification"

    local all_ok=true

    # 1. pacman.conf exists
    if [[ -f "$PACMAN_CONF" ]]; then
        success "pacman.conf exists ($PACMAN_CONF)"
    else
        error "pacman.conf not found ($PACMAN_CONF)"
        all_ok=false
    fi

    # 2. source ignore.conf exists in dotfiles
    if [[ -f "$IGNORE_CONF_SOURCE" ]]; then
        success "ignore.conf exists in dotfiles"
    else
        error "ignore.conf missing: $IGNORE_CONF_SOURCE"
        all_ok=false
    fi

    # 3. symlink exists and points to the right place
    if [[ -L "$SYMLINK_PATH" ]]; then
        local target
        target="$(readlink -f "$SYMLINK_PATH" 2>/dev/null || echo '')"
        local expected
        expected="$(readlink -f "$IGNORE_CONF_SOURCE" 2>/dev/null || echo '')"

        if [[ "$target" == "$expected" && -n "$target" ]]; then
            success "Symlink valid: $SYMLINK_PATH → $target"
        else
            error "Symlink broken or wrong target: $SYMLINK_PATH → $target"
            warn  "Expected: $expected"
            all_ok=false
        fi
    elif [[ -e "$SYMLINK_PATH" ]]; then
        error "Path exists but is NOT a symlink: $SYMLINK_PATH"
        all_ok=false
    else
        error "Symlink missing: $SYMLINK_PATH"
        all_ok=false
    fi

    # 4. Include line exists inside [options]
    if _include_in_options; then
        success "Include configured inside [options] in pacman.conf"
    else
        error "Include missing or not inside [options]"
        warn  "Expected line: $INCLUDE_LINE"
        all_ok=false
    fi

    echo
    if $all_ok; then
        echo -e "${GREEN}${BOLD}All checks passed. Configuration is healthy.${RESET}"
    else
        echo -e "${RED}${BOLD}One or more checks failed. Run option 6 (Repair) to fix.${RESET}"
    fi
}

# Returns 0 if the Include line exists inside [options] in pacman.conf
# Uses sudo cat so the check works even if pacman.conf is root-only readable.
_include_in_options() {
    sudo cat "$PACMAN_CONF" | awk '
        /^\[options\]/ { in_opt = 1; next }
        /^\[/ { in_opt = 0 }
        in_opt && $0 == "'"$INCLUDE_LINE"'" { found = 1 }
        END { exit !found }
    '
}

# Returns 0 if the Include line exists anywhere in pacman.conf (duplicate guard)
_include_anywhere() {
    sudo cat "$PACMAN_CONF" | grep -qF "$INCLUDE_LINE"
}

# ---------------------------------------------------------------------------
# Configure IgnorePkg (symlink + Include)
# ---------------------------------------------------------------------------
cmd_configure() {
    header "Configuring IgnorePkg Integration"

    check_source_file
    require_sudo

    local needs_symlink=false
    local needs_include=false

    # ---- Step 1: Symlink ----
    if [[ -L "$SYMLINK_PATH" ]]; then
        local current_target
        current_target="$(readlink -f "$SYMLINK_PATH" 2>/dev/null || echo '')"
        local expected_target
        expected_target="$(readlink -f "$IGNORE_CONF_SOURCE")"

        if [[ "$current_target" == "$expected_target" ]]; then
            success "Symlink already valid — no change needed"
        else
            warn "Symlink exists but points to a different location:"
            warn "  Current : $current_target"
            warn "  Expected: $expected_target"
            echo -n "  Replace it? [y/N] "
            read -r reply
            if [[ "$reply" =~ ^[Yy]$ ]]; then
                needs_symlink=true
            else
                warn "Skipping symlink replacement."
            fi
        fi
    elif [[ -e "$SYMLINK_PATH" ]]; then
        # Path exists but is a regular file — refuse to overwrite silently
        die "Path exists and is not a symlink: $SYMLINK_PATH\nManually remove it first if you want to replace it."
    else
        needs_symlink=true
    fi

    if $needs_symlink; then
        info "Creating symlink: $SYMLINK_PATH → $IGNORE_CONF_SOURCE"
        sudo ln -sf "$IGNORE_CONF_SOURCE" "$SYMLINK_PATH"
        success "Symlink created"
    fi

    # ---- Step 2: Include in [options] ----
    if _include_in_options; then
        success "Include already configured inside [options] — no change needed"
    elif _include_anywhere; then
        # Line exists but outside [options] — wrong placement
        warn "Include line found in pacman.conf but NOT inside [options]."
        warn "Manual review recommended: $PACMAN_CONF"
        warn "Skipping automatic insertion to avoid duplication."
    else
        needs_include=true
    fi

    if $needs_include; then
        info "Inserting Include into [options] in $PACMAN_CONF"
        # Write to a temp file first (atomic write — no partial edits)
        local tmp
        tmp="$(sudo mktemp "$PACMAN_D_DIR/.pacman.conf.XXXXXX")"
        sudo awk '
            /^\[core\]/ && !done {
                print "'"$INCLUDE_LINE"'"
                print ""
                done = 1
            }
            { print }
        ' "$PACMAN_CONF" | sudo tee "$tmp" > /dev/null
        # chmod/chown the temp file BEFORE mv — sudo mktemp creates files as 600
        # (root-only). Setting 644 here ensures the destination inherits correct
        # world-readable permissions atomically with the mv.
        sudo chmod 644 "$tmp"
        sudo chown root:root "$tmp"
        sudo mv "$tmp" "$PACMAN_CONF"
        success "Include inserted before [core]"
    fi

    echo
    # Run verify to confirm final state
    cmd_verify
}

# ---------------------------------------------------------------------------
# Repair — re-runs configure, which is fully idempotent
# ---------------------------------------------------------------------------
cmd_repair() {
    header "Repairing Configuration"
    cmd_configure
}

# ---------------------------------------------------------------------------
# Resolve AUR helper (paru preferred, yay fallback)
# ---------------------------------------------------------------------------
_aur_helper() {
    if command -v paru &>/dev/null; then echo "paru"
    elif command -v yay &>/dev/null; then echo "yay"
    else echo ""; fi
}

# ---------------------------------------------------------------------------
# Install pacman packages (with auto-AUR fallback per package)
# ---------------------------------------------------------------------------
cmd_install_pacman() {
    header "Installing Official Packages"

    [[ -f "$PACMAN_TXT" ]] || die "File not found: $PACMAN_TXT"

    local pkgs
    pkgs="$(grep -vE '^\s*($|#)' "$PACMAN_TXT" || true)"

    if [[ -z "$pkgs" ]]; then
        warn "pacman.txt is empty — nothing to install."
        return
    fi

    # ── Sort packages: official vs needs-AUR-fallback ──────────────────────
    local official_pkgs=()
    local fallback_pkgs=()

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if pacman -Si "$pkg" &>/dev/null; then
            official_pkgs+=("$pkg")
        else
            warn "'$pkg' not found in pacman repos — will try AUR helper"
            fallback_pkgs+=("$pkg")
        fi
    done <<< "$pkgs"

    # ── Install official packages ───────────────────────────────────────────
    if [[ ${#official_pkgs[@]} -gt 0 ]]; then
        info "Official packages to install:"
        printf '    %s\n' "${official_pkgs[@]}"
        echo
        sudo pacman -S --needed "${official_pkgs[@]}"
        success "Official packages done."
    fi

    # ── Fallback: install via AUR helper ───────────────────────────────────
    if [[ ${#fallback_pkgs[@]} -gt 0 ]]; then
        local aur_helper
        aur_helper="$(_aur_helper)"
        if [[ -z "$aur_helper" ]]; then
            error "No AUR helper (paru/yay) found — cannot install: ${fallback_pkgs[*]}"
            error "Install paru or yay and re-run."
        else
            info "AUR helper ($aur_helper) will install:"
            printf '    %s\n' "${fallback_pkgs[@]}"
            echo
            "$aur_helper" -S --needed "${fallback_pkgs[@]}"
            success "AUR fallback packages done."
        fi
    fi

    echo
    success "All pacman packages processed."
}


# ---------------------------------------------------------------------------
# Install AUR packages
# ---------------------------------------------------------------------------
cmd_install_aur() {
    header "Installing AUR Packages"

    [[ -f "$AUR_TXT" ]] || die "File not found: $AUR_TXT"

    local pkgs
    pkgs="$(grep -vE '^\s*($|#)' "$AUR_TXT" || true)"

    if [[ -z "$pkgs" ]]; then
        warn "aur.txt is empty — nothing to install."
        return
    fi

    local aur_helper
    aur_helper="$(_aur_helper)"
    [[ -n "$aur_helper" ]] || die "No AUR helper found (paru/yay). Install one first."

    info "AUR helper: $aur_helper"
    info "Packages to install:"
    echo "$pkgs" | sed 's/^/    /'
    echo
    # shellcheck disable=SC2086
    "$aur_helper" -S --needed $pkgs
    success "Done."
}

# ---------------------------------------------------------------------------
# Install everything
# ---------------------------------------------------------------------------
cmd_install_all() {
    cmd_install_pacman
    cmd_install_aur
    cmd_configure
}

# ---------------------------------------------------------------------------
# Add packages to IgnorePkg via TUI
# ---------------------------------------------------------------------------
cmd_add_ignore_tui() {
    header "Add Packages to IgnorePkg"

    if ! command -v fzf &>/dev/null; then
        error "fzf is required for the TUI. Please install it first."
        echo -n "Do you want to install fzf now? [y/N]: "
        read -r install_choice
        if [[ "$install_choice" =~ ^[yY]$ ]]; then
            info "Installing fzf..."
            sudo pacman -S --needed fzf
        else
            info "Aborting."
            return
        fi
    fi

    local fzf_args=(
        --multi
        --preview 'pacman -Qi {1}'
        --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select'
        --preview-label-pos='bottom'
        --preview-window 'down:65%:wrap'
        --bind 'alt-p:toggle-preview'
        --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
        --bind 'alt-k:preview-up,alt-j:preview-down'
        --color 'pointer:red,marker:red'
    )

    info "Opening package selector (explicitly installed packages)..."
    
    local pkg_names
    pkg_names=$(pacman -Qqe | fzf "${fzf_args[@]}" || true)

    if [[ -z "$pkg_names" ]]; then
        info "No packages selected. Aborting."
        return
    fi

    local added=0
    local skipped=0

    # Ensure source file exists
    [[ -f "$IGNORE_CONF_SOURCE" ]] || touch "$IGNORE_CONF_SOURCE"

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        
        # Escape special regex characters in package name (+ and .)
        local safe_pkg="${pkg//+/\\+}"
        safe_pkg="${safe_pkg//./\\.}"
        
        # Check if already present to avoid duplicates
        # Matches: IgnorePkg = pkg, IgnorePkg=pkg, IgnorePkg = pkg1 pkg2
        if grep -qE "^[[:space:]]*IgnorePkg[[:space:]]*=.*[[:space:]]$safe_pkg([[:space:]]|$)" "$IGNORE_CONF_SOURCE" || \
           grep -qE "^[[:space:]]*IgnorePkg[[:space:]]*=[[:space:]]*$safe_pkg([[:space:]]|$)" "$IGNORE_CONF_SOURCE"; then
            warn "'$pkg' is already in ignore.conf"
            skipped=$((skipped + 1))
        else
            echo "IgnorePkg = $pkg" >> "$IGNORE_CONF_SOURCE"
            success "Added '$pkg'"
            added=$((added + 1))
        fi
    done <<< "$pkg_names"
    
    echo
    info "Summary: $added added, $skipped skipped."
}

# ---------------------------------------------------------------------------
# Show ignored packages
# ---------------------------------------------------------------------------
cmd_show_ignore() {
    header "Ignored Packages"

    if [[ -f "$IGNORE_CONF_SOURCE" ]]; then
        local content
        content="$(grep -vE '^\s*($|#)' "$IGNORE_CONF_SOURCE" || true)"
        if [[ -n "$content" ]]; then
            info "Ignored packages configuration ($IGNORE_CONF_SOURCE):"
            echo "$content" | sed 's/^/    /'
        else
            warn "No ignored packages configured in $IGNORE_CONF_SOURCE"
        fi
    else
        warn "Source file not found: $IGNORE_CONF_SOURCE"
    fi
}

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
show_menu() {
    echo -e "\n${BOLD}╔══════════════════════════════╗"
    echo    "║     Package Setup Utility    ║"
    echo -e "╚══════════════════════════════╝${RESET}"
    echo
    echo "  1. Install pacman packages"
    echo "  2. Install AUR packages"
    echo "  3. Install everything"
    echo "  4. Configure IgnorePkg  (symlink + Include)"
    echo "  5. Verify configuration"
    echo "  6. Repair configuration"
    echo "  7. Add packages to IgnorePkg (TUI)"
    echo "  8. Show ignored packages"
    echo "  9. Exit"
    echo
    echo -n "Choose [1-9]: "
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    # Non-interactive mode: accept action as first argument
    if [[ $# -gt 0 ]]; then
        case "$1" in
            install-pacman) cmd_install_pacman ;;
            install-aur)    cmd_install_aur ;;
            install-all)    cmd_install_all ;;
            configure)      cmd_configure ;;
            verify)         cmd_verify ;;
            repair)         cmd_repair ;;
            add-ignore)     cmd_add_ignore_tui ;;
            show-ignore)    cmd_show_ignore ;;
            *) die "Unknown command: $1\nUsage: $0 [install-pacman|install-aur|install-all|configure|verify|repair|add-ignore|show-ignore]" ;;
        esac
        exit 0
    fi

    # Interactive menu
    while true; do
        show_menu
        read -r choice

        case "$choice" in
            1) cmd_install_pacman ;;
            2) cmd_install_aur ;;
            3) cmd_install_all ;;
            4) cmd_configure ;;
            5) cmd_verify ;;
            6) cmd_repair ;;
            7) cmd_add_ignore_tui ;;
            8) cmd_show_ignore ;;
            9) echo -e "\n${CYAN}Goodbye.${RESET}\n"; exit 0 ;;
            *) warn "Invalid choice. Enter a number from 1 to 9." ;;
        esac

        echo
        echo -n "Press Enter to return to menu..."
        read -r
    done
}

main "$@"
