#!/usr/bin/env bash
# Project Opener — walker dmenu-based project selector + IDE picker
# Shows folders in ~/Projects, then lists installed IDEs to open with.

set -euo pipefail

PROJECTS_DIR="$HOME/Projects"
TERMINAL="foot"

# ============= IDE REGISTRY =============
# Format: "display-name|check-binary|launch-command-template"
# Use {path} as placeholder for the project path
declare -A IDE_BINS=(
  ["VSCode"]="code"
  ["Antigravity"]="antigravity-ide"
  ["Neovim"]="nvim"
  ["OpenCode"]="opencode"
  ["Zed"]="zeditor"
  ["ClaudeCode"]="claude"
)

declare -A IDE_CMDS=(
  ["VSCode"]="uwsm app -- code {path}"
  ["Antigravity"]="uwsm app -- antigravity-launch {path}"
  ["Neovim"]="uwsm app -- $TERMINAL --working-directory {path} -e nvim {path}"
  ["OpenCode"]="uwsm app -- $TERMINAL --working-directory {path} -e opencode"
  ["Zed"]="uwsm app -- zeditor {path}"
  ["ClaudeCode"]="uwsm app -- $TERMINAL --working-directory {path} -e claude"
)

# ============= ENSURE PROJECTS DIR =============
if [[ ! -d "$PROJECTS_DIR" ]]; then
  choice="$(printf 'Yes, create ~/Projects\nCancel' | \
    walker --dmenu --placeholder "~/Projects not found — create it?" 2>/dev/null || true)"
  [[ "$choice" == "Yes, create ~/Projects" ]] || exit 0
  mkdir -p "$PROJECTS_DIR"
  notify-send "Projects" "Created ~/Projects" -t 2000
fi

# ============= LIST PROJECTS =============
mapfile -t projects < <(
  {
    find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null || true
    for name in Dotfiles dotfiles .dotfiles .Dotfiles .files; do
      [[ -d "$HOME/$name" ]] && echo "$name"
    done
  } | sort -u
)

if [[ ${#projects[@]} -eq 0 ]]; then
  choice="$(printf 'No projects found\nOpen ~/Projects in Files\nCancel' | \
    walker --dmenu --placeholder "~/Projects is empty" 2>/dev/null || true)"
  [[ "$choice" == "Open ~/Projects in Files" ]] && nautilus "$PROJECTS_DIR" &
  exit 0
fi

project_list="$(printf '%s\n' "${projects[@]}")"
selected_project="$(printf '%s' "$project_list" | \
  walker --dmenu --placeholder "Open project..." 2>/dev/null || true)"

[[ -z "$selected_project" ]] && exit 0

project_path="$PROJECTS_DIR/$selected_project"
if [[ "$selected_project" =~ ^(\.[Dd]otfiles|[Dd]otfiles|\.files)$ ]] && [[ -d "$HOME/$selected_project" ]]; then
  project_path="$HOME/$selected_project"
fi

# ============= LIST INSTALLED IDEs =============
installed_ides=()
for ide in "VSCode" "Antigravity" "Neovim" "OpenCode" "Zed" "ClaudeCode"; do
  bin="${IDE_BINS[$ide]}"
  command -v "$bin" >/dev/null 2>&1 && installed_ides+=("$ide")
done

if [[ ${#installed_ides[@]} -eq 0 ]]; then
  notify-send "Project Opener" "No supported IDEs found" -t 3000
  exit 1
fi

ide_list="$(printf '%s\n' "${installed_ides[@]}")"
selected_ide="$(printf '%s' "$ide_list" | \
  walker --dmenu --placeholder "Open '$selected_project' in..." 2>/dev/null || true)"

[[ -z "$selected_ide" ]] && exit 0

# ============= LAUNCH IDE =============
cmd_template="${IDE_CMDS[$selected_ide]}"

# Safe substitution: replace {path} literally — no eval
# Split template into array, substitute {path} in each token
read -ra cmd_parts <<< "$cmd_template"
for i in "${!cmd_parts[@]}"; do
  cmd_parts[$i]="${cmd_parts[$i]//\{path\}/$project_path}"
done

"${cmd_parts[@]}" &
disown

notify-send "Opening Project" "$selected_project → $selected_ide" -t 2000
