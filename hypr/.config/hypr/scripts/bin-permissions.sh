#!/usr/bin/env bash
# bin-permissions.sh — View and fix executable permissions for stowed bins
#
# Terminal-only script. Lists stowed bins (~/.local/bin symlinks pointing into
# ~/dotfiles/bin/) with their executable status. Select any entry to chmod +x.
#
# Launched as app class "user-script" so Hyprland floats it.

# ── Set terminal app ID for Hyprland float rule ───────────────────────────────
export WAYLAND_APP_ID="user-script"

BIN_DIR="$HOME/.local/bin"
STOW_BIN_DIR="$HOME/dotfiles/bin"

# ── Colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GRN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[1;33m'
  CYN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RST='\033[0m'
else
  GRN=''; RED=''; YEL=''; CYN=''; BOLD=''; DIM=''; RST=''
fi

header() { echo -e "\n${BOLD}${CYN}$*${RST}"; }
info()    { echo -e "  ${CYN}→${RST} $*"; }
ok()      { echo -e "  ${GRN}✅ X ${RST} $*"; }
bad()     { echo -e "  ${RED}❌   ${RST} $*"; }
sep()     { echo -e "${DIM}──────────────────────────────────────────${RST}"; }

# ── Collect stowed bins ───────────────────────────────────────────────────────
declare -a stowed_names
declare -a stowed_ok      # parallel array: "yes"/"no"

while IFS= read -r -d '' entry; do
  [[ -L "$entry" ]] || continue
  target=$(readlink -f "$entry" 2>/dev/null)
  [[ "$target" == "$STOW_BIN_DIR"* ]] || continue
  name=$(basename "$entry")
  stowed_names+=("$name")
  if [[ -x "$entry" ]]; then
    stowed_ok+=("yes")
  else
    stowed_ok+=("no")
  fi
done < <(find "$BIN_DIR" -maxdepth 1 -print0 | sort -z)

# ── Main loop ─────────────────────────────────────────────────────────────────
while true; do
  clear
  header "Stowed Bin Permissions — ${BIN_DIR}"
  sep
  echo ""

  if [[ ${#stowed_names[@]} -eq 0 ]]; then
    echo -e "  ${YEL}⚠  No stowed bins found in ${BIN_DIR}${RST}"
    echo ""
    sep
    echo ""
    read -r -p "  Press Enter to exit..." _
    exit 0
  fi

  # ── Print numbered list ──────────────────────────────────────────────────────
  local_bad_indices=()
  for i in "${!stowed_names[@]}"; do
    num=$(( i + 1 ))
    if [[ "${stowed_ok[$i]}" == "yes" ]]; then
      ok "[$num] ${stowed_names[$i]}"
    else
      bad "[$num] ${stowed_names[$i]}"
      local_bad_indices+=("$num")
    fi
  done

  echo ""
  sep

  # Check if everything is already executable
  if [[ ${#local_bad_indices[@]} -eq 0 ]]; then
    echo ""
    echo -e "  ${GRN}${BOLD}All stowed bins are executable. ✅${RST}"
    echo ""
    read -r -p "  Press Enter to exit..." _
    exit 0
  fi

  echo ""
  echo -e "  ${YEL}Enter a number to make that bin executable, or 'q' to quit:${RST}"
  echo ""
  read -r -p "  Choice: " choice
  echo ""

  # ── Handle quit ──────────────────────────────────────────────────────────────
  [[ "$choice" =~ ^[qQ]$ ]] && { echo -e "  ${DIM}Bye!${RST}\n"; exit 0; }

  # ── Validate numeric input ───────────────────────────────────────────────────
  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo -e "  ${RED}✗  Invalid input. Enter a number.${RST}"
    sleep 1
    continue
  fi

  idx=$(( choice - 1 ))
  if (( idx < 0 || idx >= ${#stowed_names[@]} )); then
    echo -e "  ${RED}✗  Number out of range (1–${#stowed_names[@]}).${RST}"
    sleep 1
    continue
  fi

  name="${stowed_names[$idx]}"
  bin_path="$BIN_DIR/$name"

  # ── Already executable ────────────────────────────────────────────────────────
  if [[ "${stowed_ok[$idx]}" == "yes" ]]; then
    echo -e "  ${GRN}✅  '$name' is already executable. Nothing to do.${RST}"
    sleep 1
    continue
  fi

  # ── Apply chmod +x ────────────────────────────────────────────────────────────
  info "Making '${BOLD}$name${RST}' executable (sudo required)..."
  echo ""
  if sudo chmod +x "$bin_path"; then
    stowed_ok[$idx]="yes"
    echo ""
    echo -e "  ${GRN}${BOLD}✅  chmod +x applied to '$name' successfully.${RST}"
    # Also chmod the real file in the stow tree
    real_path=$(readlink -f "$bin_path")
    sudo chmod +x "$real_path" 2>/dev/null || true
  else
    echo ""
    echo -e "  ${RED}${BOLD}❌  Failed to apply chmod +x to '$name'.${RST}"
  fi

  echo ""
  read -r -p "  Press Enter to continue..." _
done
