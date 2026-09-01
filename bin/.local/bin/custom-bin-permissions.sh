#!/usr/bin/env bash
# custom-bin-permissions.sh — View and fix executable permissions in ~/.local/bin
#
# Launched as app class "custom-script" so Hyprland floats it.

export WAYLAND_APP_ID="custom-script"

readonly SCAN_DIR="$HOME/.local/bin"
readonly STOW_BIN_DIR="$HOME/dotfiles/bin"

# ── Colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GRN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[1;33m'
  CYN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RST='\033[0m'
else
  GRN=''; RED=''; YEL=''; CYN=''; BOLD=''; DIM=''; RST=''
fi

header() { echo -e "\n${BOLD}${CYN}$*${RST}"; }
sep()    { echo -e "${DIM}──────────────────────────────────────────${RST}"; }

# ── Data Collection ───────────────────────────────────────────────────────────
declare -a file_paths file_names file_perms file_owners file_ok file_targets

collect_files() {
  file_paths=(); file_names=(); file_perms=(); file_owners=(); file_ok=(); file_targets=()

  while IFS= read -r -d '' entry; do
    local name; name=$(basename "$entry")
    local perm;  perm=$(stat  -c '%A (%a)' "$entry" 2>/dev/null || echo "???")
    local owner; owner=$(stat -c '%U'       "$entry" 2>/dev/null || echo "???")
    local target=""
    [[ -L "$entry" ]] && target=$(readlink -f "$entry" 2>/dev/null)
    local is_exec="no"
    [[ -x "$entry" ]] && is_exec="yes"

    file_paths+=("$entry")
    file_names+=("$name")
    file_perms+=("$perm")
    file_owners+=("$owner")
    file_ok+=("$is_exec")
    file_targets+=("$target")
  done < <(find "$SCAN_DIR" -maxdepth 1 \( -type f -o -type l \) -print0 2>/dev/null | sort -z)
}

# ── Make Executable ───────────────────────────────────────────────────────────
make_executable() {
  local path="$1" target="$2" owner="$3"
  local cmd_prefix=""
  [[ ! -w "$path" && "$owner" != "$USER" ]] && cmd_prefix="sudo "

  if $cmd_prefix chmod +x "$path" 2>/dev/null; then
    # Also chmod the symlink target if it lives in the stow dir
    if [[ -n "$target" && -f "$target" && "$target" == "$STOW_BIN_DIR"* ]]; then
      chmod +x "$target" 2>/dev/null || true
    fi
    echo -e "  ${GRN}✅ $(basename "$path") — executable permissions applied${RST}"
  else
    echo -e "  ${RED}❌ $(basename "$path") — failed to apply permissions${RST}"
  fi
}

# ── Interactive TUI ───────────────────────────────────────────────────────────
while true; do
  collect_files
  local_total=${#file_paths[@]}
  bad_count=0
  for s in "${file_ok[@]}"; do [[ "$s" == "no" ]] && ((bad_count++)); done

  clear
  header "Bin Permissions  —  ${SCAN_DIR}"
  sep
  echo -e "  ${BOLD}Files:${RST}  ${local_total} total  |  ${GRN}$(( local_total - bad_count )) executable${RST}  |  ${RED}${bad_count} not executable${RST}"
  sep
  echo ""

  if [[ $local_total -eq 0 ]]; then
    echo -e "  ${YEL}⚠  No files found in ${SCAN_DIR}${RST}"
  else
    for (( i=0; i<local_total; i++ )); do
      local num=$(( i + 1 ))
      local display="${file_names[$i]}"
      if [[ -n "${file_targets[$i]}" ]]; then
        local short="${file_targets[$i]/#$HOME/\~}"
        display="${file_names[$i]} ${DIM}→ ${short}${RST}"
      fi
      if [[ "${file_ok[$i]}" == "yes" ]]; then
        echo -e "  ${GRN}✅${RST} [${num}] ${display} ${DIM}(${file_perms[$i]} · ${file_owners[$i]})${RST}"
      else
        echo -e "  ${RED}❌${RST} [${num}] ${display} ${DIM}(${file_perms[$i]} · ${file_owners[$i]})${RST}"
      fi
    done
  fi

  echo ""
  sep
  echo -e "  ${BOLD}[1-${local_total}]${RST} Toggle Executable  ${BOLD}[a]${RST} Make ALL Executable  ${BOLD}[r]${RST} Refresh  ${BOLD}[q]${RST} Quit"
  echo ""
  read -r -p "  Choice: " choice
  echo ""

  case "$choice" in
    [qQ])
      echo -e "  ${DIM}Bye!${RST}"
      exit 0
      ;;
    [rR])
      continue
      ;;
    [aA])
      fixed=0
      for i in "${!file_paths[@]}"; do
        if [[ "${file_ok[$i]}" == "no" ]]; then
          make_executable "${file_paths[$i]}" "${file_targets[$i]}" "${file_owners[$i]}"
          ((fixed++))
        fi
      done
      echo ""
      if (( fixed == 0 )); then
        echo -e "  ${GRN}All files are already executable.${RST}"
      else
        echo -e "  ${GRN}Fixed ${fixed} file(s).${RST}"
      fi
      read -r -p "  Press Enter to continue..." _
      ;;
    *)
      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < local_total )); then
          if [[ "${file_ok[$idx]}" == "yes" ]]; then
            echo -e "  ${GRN}✅ '${file_names[$idx]}' is already executable.${RST}"
          else
            make_executable "${file_paths[$idx]}" "${file_targets[$idx]}" "${file_owners[$idx]}"
          fi
          read -r -p "  Press Enter to continue..." _
        else
          echo -e "  ${RED}✗ Index out of range (1-${local_total}).${RST}"
          sleep 1
        fi
      else
        echo -e "  ${RED}✗ Invalid choice.${RST}"
        sleep 1
      fi
      ;;
  esac
done
