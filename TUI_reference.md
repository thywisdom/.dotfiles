# TUI Reference — Bash Script UI & UX Methodology
> Compiled from Omarchy (basecamp/omarchy) patterns, Charmbracelet Gum docs, and terminal UX best practices.
> Use this as a design system reference for all custom scripts in this dotfiles repo.

---

## 1. Core Tool: `gum` (Charmbracelet)

Omarchy's entire TUI layer is built on **`gum`** — a single binary that renders glamorous terminal UI primitives.
Installed at `/usr/bin/gum` (v0.17.0), pre-themed via Catppuccin Mocha env vars injected by Omarchy's shell config.

### Available `gum` Commands

| Command      | Purpose                                      | Key Flags                                                     |
|--------------|----------------------------------------------|---------------------------------------------------------------|
| `gum style`  | Apply color, border, padding, alignment      | `--border`, `--padding`, `--foreground`, `--bold`, `--width` |
| `gum confirm`| Yes/No interactive prompt                    | `--affirmative`, `--negative`, `--default`, `--timeout`      |
| `gum choose` | Single-select menu from a list               | `--header`, `--cursor`, `--selected`                          |
| `gum filter` | Fuzzy-search select from a list              | `--placeholder`, `--header`, `--limit`                        |
| `gum input`  | Single-line text input                       | `--placeholder`, `--prompt`, `--password`                     |
| `gum spin`   | Spinner while a command runs                 | `--spinner`, `--title`, `--show-output`                       |
| `gum table`  | Render a formatted data table                | `--columns`, `--widths`, `--separator`                        |
| `gum log`    | Structured log messages with levels          | `--level` (debug/info/warn/error/fatal)                       |
| `gum pager`  | Scroll through long content                  | (stdin piped content)                                         |
| `gum format` | Render markdown / template strings           | `--type` (markdown, template, code, emoji)                    |
| `gum join`   | Compose multiple styled blocks horizontally  | `--horizontal`, `--align`                                     |
| `gum write`  | Multi-line text input                        | `--placeholder`, `--header`                                   |

---

## 2. Theme: Catppuccin Mocha (Omarchy Default)

Omarchy injects a full set of `GUM_*` environment variables, automatically theming gum to match the terminal.

| Role                  | Color     | Hex       |
|-----------------------|-----------|-----------|
| Background            | Base      | `#1e1e2e` |
| Surface (selected)    | Surface0  | `#45475a` |
| Overlay / Dim         | Overlay0  | `#585b70` |
| Text (normal)         | Text      | `#cdd6f4` |
| Accent / Prompt       | Blue      | `#89b4fa` |
| Success               | Green     | `#a6e3a1` |
| Warning               | Yellow    | `#f9e2af` |
| Error / Danger        | Red       | `#f38ba8` |

> These are injected automatically from Omarchy's theme system — **do NOT set them manually** in scripts.

---

## 3. UI Patterns & Components

### 3.1 Header / Banner Block (Omarchy `omarchy-update-confirm` pattern)

```bash
gum style \
  --border normal \
  --border-foreground "#89b4fa" \
  --padding "1 2" \
  --width 60 \
  "$(gum style --bold --foreground '#cdd6f4' 'System Cleanup')" \
  "" \
  "• Arch Linux maintenance utility" \
  "• Dry-run scan before any changes"
```

### 3.2 Section Headers (inline continuous output)

```bash
echo -e "\n\033[1;37m── Pacman Cache \033[0;90m───────────────────────────────────────\033[0m"
```

### 3.3 Status Tags (lightweight, gum log or ANSI)

```bash
# Via gum log (preferred):
gum log --level info  "Scanning cleanup targets..."
gum log --level warn  "Pacman cache is large (3.2 GiB)"
gum log --level error "Permission denied: /var/lib/systemd/coredump"

# ANSI fallback:
info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }
done_() { printf "\033[1;32m[DONE]\033[0m  %s\n" "$*"; }
skip()  { printf "\033[0;90m[SKIP]\033[0m  %s\n" "$*"; }
```

### 3.4 Yes/No Confirmation (Omarchy canonical pattern)

```bash
# Pattern: info box → blank line → gum confirm
gum style --border normal --padding "1 2" \
  "⚠  This will permanently empty the Trash." \
  "" \
  "Files cannot be recovered after this step."

echo

if gum confirm "Proceed with emptying Trash?"; then
  # do the action
else
  echo "Skipped."
fi
```

Auto-shows keyboard hints: `↔ toggle · enter submit · y Yes · n No`

### 3.5 Spinner (while command runs)

```bash
# Fire-and-measure pattern:
gum spin --spinner dot --title "Vacuuming systemd journal..." -- \
  sudo journalctl --vacuum-size=200M

# With output capture:
gum spin --spinner globe --title "Cleaning pacman cache..." \
  --show-output -- sudo pacman -Scc --noconfirm
```

**Spinner styles**: `line` `dot` `minidot` `jump` `pulse` `points` `globe` `moon` `monkey` `meter` `hamburger`

### 3.6 Choose / Select Menu (replaces numbered menus)

```bash
CHOICE=$(gum choose \
  --header "Select journal vacuum policy:" \
  "Conservative — 14d / 200M (Recommended)" \
  "Moderate — 7d / 100M" \
  "Aggressive — vacuum to 1M" \
  "Skip")
```

### 3.7 Table Display (summary / dry-run)

```bash
printf "Category,Before,After,Reclaimed,Status\n" > /tmp/cleanup_table
printf "Pacman Cache,3.2 GiB,0 B,3.2 GiB,✓ Done\n" >> /tmp/cleanup_table
printf "Journal,800 MiB,200 MiB,600 MiB,✓ Done\n" >> /tmp/cleanup_table
cat /tmp/cleanup_table | gum table --widths 20,12,12,12,10 --separator ","
```

### 3.8 "Done" Completion Signal (Omarchy `omarchy-show-done` pattern)

```bash
echo
gum spin --spinner globe --title "Done! Press any key to close..." -- \
  bash -c 'read -n 1 -s'
```

---

## 4. Script Launch & Hyprland Window Rules

Scripts that run in a floating terminal must set their Wayland app-id:

```bash
# At the very top of the script
export WAYLAND_APP_ID="custom-scripts"
```

Matching Hyprland rule in `windowrules.lua` (line 15):
```lua
-- Custom scripts launched in terminal — large floating centered rectangle
o.window("^((custom|user)-scripts?)$", { float = true, size = { 1350, 708 }, center = true })
```

The class is matched by Hyprland via the app-id set on the terminal process. Use `custom-scripts` (matches the rule `(custom|user)-scripts?`).

---

## 5. Flow Design Principles

### 5.1 Two-Phase Flow (Inspect → Act)

1. **Phase 1 — Inspect / Dry-run**: Measure all targets, display system info + freeable space table.
   - Show any `[WARN]` / `[ERROR]` for inaccessible paths here.
   - No changes made.
2. **Affirmation Gate**: Single `gum confirm` to proceed to cleanup.
3. **Phase 2 — Execute**: Sequential cleanup stages with per-stage spinners and before/after accounting.
4. **Summary**: Final table of all stages' reclaimed space + status.

### 5.2 Progressive Disclosure

- Show total freeable space **before** asking permission.
- Dangerous stages (Trash, Snapper delete) require **explicit named confirmation** even in batch mode.

### 5.3 Batch vs Interactive Mode

| Mode         | Flag               | Behavior                                             |
|--------------|--------------------|------------------------------------------------------|
| Interactive  | Default (no flag)  | Each dangerous stage asks `gum confirm`              |
| Batch/Auto   | `--yes` / `-y`     | Safe stages auto-proceed; dangerous still confirm   |
| Dry-run      | `--dry-run` / `-d` | Inspect only, zero changes made                     |

### 5.4 Error Display Rules

| Error Type             | Display Method                               | Behavior              |
|------------------------|----------------------------------------------|-----------------------|
| Path not found         | `gum log --level warn` + path                | Skip, continue        |
| Permission denied      | `gum log --level error` + path + suggestion  | Skip, continue        |
| Command failed         | `gum log --level error` + exit code shown    | Record PARTIAL/FAILED |
| Dangerous op           | `gum style` warning box + explicit confirm   | Block until confirmed |

### 5.5 Sudo Lifecycle (Omarchy `omarchy-sudo-keepalive` pattern)

```bash
init_sudo() {
  [[ $EUID -eq 0 ]] && { gum log --level error "Do not run as root."; exit 1; }
  sudo -v
  while true; do sudo -n true; sleep 60; done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap "kill $SUDO_KEEPALIVE_PID 2>/dev/null" EXIT
}
```

---

## 6. Color Quick Reference

```bash
BLUE="#89b4fa"      # Accent, prompts, section titles
GREEN="#a6e3a1"     # Success, reclaimed space
YELLOW="#f9e2af"    # Warnings
RED="#f38ba8"       # Errors, dangerous ops
GRAY="#585b70"      # Dim text, paths, metadata
TEXT="#cdd6f4"      # Normal body text
SURFACE="#45475a"   # Selected / highlighted background
```

---

## 7. Anti-Patterns to Avoid

| ❌ Anti-Pattern                           | ✅ Better Approach                              |
|-------------------------------------------|--------------------------------------------------|
| `read -rp "Proceed? [y/N]:"` plain text   | `gum confirm "Proceed?"` with styled info box   |
| Numbered menu `1) A 2) B 3) C`            | `gum choose` interactive selector               |
| `printf` spinner loops (busy-wait)        | `gum spin -- <command>`                         |
| Asking permission after starting action   | Always inspect → confirm → execute              |
| Hardcoded ANSI without `NO_COLOR` check   | Use gum (handles it) or check `[[ -t 1 ]]`     |
| No final summary                          | Always end with summary table                   |

---

## 8. Script Template Structure

```bash
#!/usr/bin/env bash
# script-name — Short description
set -euo pipefail

# 1. Wayland app-id for Hyprland float rule
export WAYLAND_APP_ID="custom-scripts"

# 2. Sudo keepalive (once at start)
init_sudo() {
  [[ $EUID -eq 0 ]] && { echo "Do not run as root."; exit 1; }
  sudo -v
  while true; do sudo -n true; sleep 60; done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap "kill $SUDO_KEEPALIVE_PID 2>/dev/null" EXIT
}

# 3. Phase 1: Inspect (dry-run, no changes)
phase_inspect() {
  gum style --border normal --padding "1 2" \
    "System Cleanup — Dry Run" "" "Scanning targets..."
  # ... show table of sizes
}

# 4. Affirmation gate
confirm_proceed() {
  echo
  if ! gum confirm "Proceed with cleanup?"; then
    echo "Cancelled."
    exit 0
  fi
}

# 5. Phase 2: Execute stages
stage_example() {
  echo -e "\n\033[1;37m── Stage Name \033[0;90m────────────────────\033[0m"
  local before; before=$(get_size /some/path)
  gum spin --spinner dot --title "Cleaning..." -- sudo rm -rf /some/path
  local after; after=$(get_size /some/path)
  gum log --level info "Reclaimed: $((before - after)) bytes"
}

# 6. Summary
show_summary() {
  printf "Stage,Before,After,Status\n..." | gum table
}

# 7. Entry point
main() {
  init_sudo
  phase_inspect
  confirm_proceed
  stage_example
  show_summary
  gum spin --spinner globe --title "Done! Press any key..." -- bash -c 'read -n 1 -s'
}
main "$@"
```

---

## 9. References

- [`gum` GitHub](https://github.com/charmbracelet/gum) — Charmbracelet's TUI toolkit
- Omarchy live scripts at `~/.local/share/omarchy/bin/`:
  - `omarchy-update-confirm` — gum style box + gum confirm pattern
  - `omarchy-show-done` — gum spin completion pattern
  - `omarchy-sudo-keepalive` — sudo single-auth keepalive
  - `omarchy-tui-install` — gum input / choose interactive prompts
  - `omarchy-update` — full staged flow with error traps
- [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) — color palette
- Hyprland windowrules: `hypr/.config/hypr/windowrules.lua`
