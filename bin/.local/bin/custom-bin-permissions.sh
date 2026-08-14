#!/usr/bin/env bash
# custom-bin-permissions.sh — View and fix executable permissions systemwide
#
# Terminal-only TUI & CLI script. Lists files in a given directory with their
# executable status, owner, permissions, and symlink targets.
# Provides options to make individual files or ALL files executable.
#
# Launched as app class "custom-script" so Hyprland floats it.

export WAYLAND_APP_ID="custom-script"

# ── Configuration ────────────────────────────────────────────────────────────
STOW_BIN_DIR="$HOME/dotfiles/bin"
DEFAULT_BIN_DIR="$HOME/.local/bin"

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

# ── CLI Usage ─────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [directory]

Options:
  -h, --help        Show this help message.
  -a, --all         Non-interactively make all scanned files executable.
  -s, --stowed      Limit scan to stowed dotfiles symlinks in ~/.local/bin.
  -t, --toggleshow  Show only non-executable files in output.

Examples:
  $(basename "$0") --stowed
  $(basename "$0") /usr/local/bin
  $(basename "$0") --all ~/.local/bin
EOF
  exit 0
}

# ── Parse Command Line Arguments ──────────────────────────────────────────────
NON_INTERACTIVE=false
STOWED_ONLY=false
SHOW_ONLY_NON_EXEC=false
SCAN_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -a|--all)
      NON_INTERACTIVE=true
      shift
      ;;
    -s|--stowed)
      STOWED_ONLY=true
      shift
      ;;
    -t|--toggleshow)
      SHOW_ONLY_NON_EXEC=true
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      SCAN_DIR="$1"
      shift
      ;;
  esac
done

# Initialize state
if [[ -z "$SCAN_DIR" ]]; then
  if [[ "$STOWED_ONLY" == "true" ]]; then
    SCAN_DIR="$DEFAULT_BIN_DIR"
  else
    # Default to user local bin directory
    SCAN_DIR="$DEFAULT_BIN_DIR"
  fi
fi

# Make sure scan directory exists
if [[ ! -d "$SCAN_DIR" ]]; then
  echo "Error: Directory '$SCAN_DIR' does not exist." >&2
  exit 1
fi

# ── Data Collection ───────────────────────────────────────────────────────────
declare -a file_paths
declare -a file_names
declare -a file_perms
declare -a file_owners
declare -a file_ok      # "yes"/"no"
declare -a file_targets # Symlink targets or empty

collect_files() {
  file_paths=()
  file_names=()
  file_perms=()
  file_owners=()
  file_ok=()
  file_targets=()

  local entries=()
  while IFS= read -r -d '' entry; do
    # Filter if stowed-only is requested
    if [[ "$STOWED_ONLY" == "true" ]]; then
      [[ -L "$entry" ]] || continue
      local target
      target=$(readlink -f "$entry" 2>/dev/null)
      [[ "$target" == "$STOW_BIN_DIR"* ]] || continue
    fi
    entries+=("$entry")
  done < <(find "$SCAN_DIR" -maxdepth 1 -type f -o -type l -print0 2>/dev/null | sort -z)

  for entry in "${entries[@]}"; do
    local name
    name=$(basename "$entry")
    local perm
    perm=$(stat -c '%A (%a)' "$entry" 2>/dev/null || echo "???")
    local owner
    owner=$(stat -c '%U' "$entry" 2>/dev/null || echo "???")
    
    local target=""
    if [[ -L "$entry" ]]; then
      target=$(readlink -f "$entry" 2>/dev/null)
    fi

    local is_exec="no"
    if [[ -x "$entry" ]]; then
      is_exec="yes"
    fi

    # Apply filter: Show only non-executable
    if [[ "$SHOW_ONLY_NON_EXEC" == "true" && "$is_exec" == "yes" ]]; then
      continue
    fi

    file_paths+=("$entry")
    file_names+=("$name")
    file_perms+=("$perm")
    file_owners+=("$owner")
    file_ok+=("$is_exec")
    file_targets+=("$target")
  done
}

# ── Permission Applier Helper ─────────────────────────────────────────────────
make_executable() {
  local path="$1"
  local target="$2"
  local owner="$3"
  local success=true

  info "Setting executable permissions on $(basename "$path")..."

  # Decide if sudo is needed based on write access / ownership
  local cmd_prefix=""
  if [[ ! -w "$path" && "$owner" != "$USER" ]]; then
    cmd_prefix="sudo "
    info "Elevated permissions (sudo) required to modify this file."
  fi

  # Apply chmod +x to the entry
  if $cmd_prefix chmod +x "$path"; then
    # If symlink, make sure real target is also executable
    if [[ -n "$target" && -f "$target" ]]; then
      local target_owner
      target_owner=$(stat -c '%U' "$target" 2>/dev/null || echo "$USER")
      local target_cmd=""
      if [[ ! -w "$target" && "$target_owner" != "$USER" ]]; then
        target_cmd="sudo "
      fi
      $target_cmd chmod +x "$target" 2>/dev/null || true
    fi
  else
    success=false
  fi

  if [[ "$success" == "true" ]]; then
    echo -e "  ${GRN}✅ Executable permissions applied successfully!${RST}"
  else
    echo -e "  ${RED}❌ Failed to apply executable permissions.${RST}"
  fi
  return 0
}

# ── Handle Non-Interactive Mode ───────────────────────────────────────────────
if [[ "$NON_INTERACTIVE" == "true" ]]; then
  collect_files
  non_exec_count=0
  for i in "${!file_paths[@]}"; do
    if [[ "${file_ok[$i]}" == "no" ]]; then
      make_executable "${file_paths[$i]}" "${file_targets[$i]}" "${file_owners[$i]}"
      ((non_exec_count++))
    fi
  done
  echo "Non-interactive run completed. Fixed $non_exec_count files."
  exit 0
fi

# ── Interactive TUI Mode ──────────────────────────────────────────────────────
PAGE=0
PAGE_SIZE=25

while true; do
  collect_files
  total_files=${#file_paths[@]}

  # Calculate bad count
  bad_count=0
  for status in "${file_ok[@]}"; do
    [[ "$status" == "no" ]] && ((bad_count++))
  done

  clear
  header "Bin Permissions Manager"
  sep
  echo -e "  ${BOLD}Directory:${RST}   ${SCAN_DIR}"
  echo -e "  ${BOLD}Scope:${RST}       $( [[ "$STOWED_ONLY" == "true" ]] && echo "Stowed Dotfiles Symlinks Only" || echo "All Files in Directory" )"
  echo -e "  ${BOLD}Filters:${RST}     $( [[ "$SHOW_ONLY_NON_EXEC" == "true" ]] && echo -e "${RED}Showing Non-Executable Only${RST}" || echo "Showing All Files" )"
  echo -e "  ${BOLD}Status:${RST}      Total: ${total_files} | ${GRN}Executable: $(( total_files - bad_count ))${RST} | ${RED}Non-Executable: ${bad_count}${RST}"
  sep
  echo ""

  if [[ $total_files -eq 0 ]]; then
    echo -e "  ${YEL}⚠  No files found matching the current scope/filters.${RST}"
    echo ""
  else
    # Paginate
    start_idx=$(( PAGE * PAGE_SIZE ))
    end_idx=$(( start_idx + PAGE_SIZE - 1 ))
    if (( end_idx >= total_files )); then
      end_idx=$(( total_files - 1 ))
    fi

    total_pages=$(( (total_files + PAGE_SIZE - 1) / PAGE_SIZE ))
    curr_page_num=$(( PAGE + 1 ))

    echo -e "  ${DIM}Showing entries $(( start_idx + 1 )) to $(( end_idx + 1 )) (Page ${curr_page_num} of ${total_pages})${RST}"
    echo ""

    for (( i=start_idx; i<=end_idx; i++ )); do
      num=$(( i + 1 ))
      name="${file_names[$i]}"
      perm="${file_perms[$i]}"
      owner="${file_owners[$i]}"
      target="${file_targets[$i]}"
      
      display_name="$name"
      if [[ -n "$target" ]]; then
        # Truncate target path for clean listing if needed
        short_target="${target/#$HOME/\~}"
        display_name="${name} ${DIM}→ ${short_target}${RST}"
      fi

      if [[ "${file_ok[$i]}" == "yes" ]]; then
        ok "[$num] ${display_name} ${DIM}(${perm} • ${owner})${RST}"
      else
        bad "[$num] ${display_name} ${DIM}(${perm} • ${owner})${RST}"
      fi
    done
  fi

  echo ""
  sep
  echo -e "  ${BOLD}TUI Actions:${RST}"
  echo -e "    ${BOLD}[1-${total_files}]${RST} Toggle Executable  ${BOLD}[a]${RST} Make ALL Executable"
  echo -e "    ${BOLD}[s]${RST} Switch Directory/Scope    ${BOLD}[t]${RST} Toggle View Filter"
  echo -e "    ${BOLD}[r]${RST} Rescan / Refresh          ${BOLD}[n]${RST} Next Page  ${BOLD}[p]${RST} Prev Page"
  echo -e "    ${BOLD}[q]${RST} Quit TUI"
  echo ""
  read -r -p "  Choice: " choice
  echo ""

  # Handle TUI Actions
  case "$choice" in
    [qQ])
      echo -e "  ${DIM}Exiting Bin Permissions Manager. Bye!${RST}\n"
      exit 0
      ;;
    [rR])
      PAGE=0
      continue
      ;;
    [tT])
      if [[ "$SHOW_ONLY_NON_EXEC" == "true" ]]; then
        SHOW_ONLY_NON_EXEC=false
      else
        SHOW_ONLY_NON_EXEC=true
      fi
      PAGE=0
      continue
      ;;
    [nN])
      if (( (PAGE + 1) * PAGE_SIZE < total_files )); then
        ((PAGE++))
      fi
      continue
      ;;
    [pP])
      if (( PAGE > 0 )); then
        ((PAGE--))
      fi
      continue
      ;;
    [aA])
      # Bulk fix
      collect_files
      fixed=0
      for i in "${!file_paths[@]}"; do
        if [[ "${file_ok[$i]}" == "no" ]]; then
          make_executable "${file_paths[$i]}" "${file_targets[$i]}" "${file_owners[$i]}"
          ((fixed++))
        fi
      done
      echo ""
      read -r -p "  Completed! Fixed ${fixed} files. Press Enter to continue..." _
      PAGE=0
      ;;
    [sS])
      # Switch directory / scope TUI selection
      clear
      header "Select Scan Scope"
      sep
      echo "  [1] Stowed Dotfiles Symlinks (~/.local/bin pointing to ~/dotfiles)"
      echo "  [2] User Local Bin folder (~/.local/bin - all files)"
      echo "  [3] System Executables (/usr/bin)"
      echo "  [4] System Local Executables (/usr/local/bin)"
      echo "  [5] Custom Path"
      echo "  [b] Go Back"
      echo ""
      read -r -p "  Selection (1-5/b): " scope_sel
      
      case "$scope_sel" in
        1)
          SCAN_DIR="$DEFAULT_BIN_DIR"
          STOWED_ONLY=true
          ;;
        2)
          SCAN_DIR="$DEFAULT_BIN_DIR"
          STOWED_ONLY=false
          ;;
        3)
          SCAN_DIR="/usr/bin"
          STOWED_ONLY=false
          ;;
        4)
          SCAN_DIR="/usr/local/bin"
          STOWED_ONLY=false
          ;;
        5)
          echo ""
          read -r -p "  Enter absolute directory path: " custom_path
          # Resolve tilde if typed
          custom_path="${custom_path/#\~/$HOME}"
          if [[ -d "$custom_path" ]]; then
            SCAN_DIR="$custom_path"
            STOWED_ONLY=false
          else
            echo -e "\n  ${RED}Error: Directory '$custom_path' does not exist!${RST}"
            sleep 2
          fi
          ;;
      esac
      PAGE=0
      ;;
    *)
      # Numeric input choice
      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < total_files )); then
          if [[ "${file_ok[$idx]}" == "yes" ]]; then
            echo -e "  ${GRN}✅ '${file_names[$idx]}' is already executable. Nothing to do.${RST}"
            sleep 1
          else
            make_executable "${file_paths[$idx]}" "${file_targets[$idx]}" "${file_owners[$idx]}"
            echo ""
            read -r -p "  Press Enter to continue..." _
          fi
        else
          echo -e "  ${RED}✗ Index out of range (1-${total_files}).${RST}"
          sleep 1.5
        fi
      else
        echo -e "  ${RED}✗ Invalid choice. Try again.${RST}"
        sleep 1
      fi
      ;;
  esac
done
