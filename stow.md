# Managing Dotfiles with GNU Stow

A beginner-friendly, step-by-step guide to safely linking, managing, and troubleshooting scripts and configs using GNU Stow in this dotfiles repository.

---

## 1. How GNU Stow Works

**GNU Stow** is a symlink farm manager. Instead of manually copying or symlinking config files into your home directory (`~`), Stow creates and manages symlinks automatically based on package directories.

Each folder in `~/dotfiles/` corresponds to a **package**. Stow mirrors the structure inside each package directly into your target directory (by default, your `$HOME` directory):

```
~/dotfiles/
├── bin/
│   └── .local/
│       └── bin/
│           ├── custom-antigravity-launch  ──(stow bin)──> ~/.local/bin/custom-antigravity-launch
│           ├── custom-bin-permissions.sh  ──(stow bin)──> ~/.local/bin/custom-bin-permissions.sh
│           ├── custom-keyboard-rgb.sh     ──(stow bin)──> ~/.local/bin/custom-keyboard-rgb.sh
│           ├── custom-music-workspace     ──(stow bin)──> ~/.local/bin/custom-music-workspace
│           ├── custom-project-open.sh     ──(stow bin)──> ~/.local/bin/custom-project-open.sh
│           ├── custom-system-cleanup      ──(stow bin)──> ~/.local/bin/custom-system-cleanup
│           ├── custom-unified-menu.sh     ──(stow bin)──> ~/.local/bin/custom-unified-menu.sh
│           └── custom-vault-sync.sh       ──(stow bin)──> ~/.local/bin/custom-vault-sync.sh
└── hypr/
    └── .config/
        └── hypr/                          ──(stow hypr)─> ~/.config/hypr/
```

### Why move scripts into `~/.local/bin`?
1. **Global Access in `$PATH`**: `~/.local/bin` is already in your `$PATH` (configured via `hypr/envs.lua` and shell profile). Any script placed here can be invoked from anywhere—terminals, keybindings in `bindings.lua`, menus, and other scripts—simply by name (e.g. `custom-unified-menu.sh`) without hardcoding `/home/suman/...`.
2. **Clean Separation**: Keeps Hyprland configs focused on window manager logic, and centralizes all executable tools in standard user binary paths.

---

## 2. Script Migration Summary

The custom Hyprland scripts and home bin scripts have been moved to the `bin` package and renamed with the `custom-` prefix:

| Old Path/Location | New Location (`bin/.local/bin/`) | Executable Command Name |
| :--- | :--- | :--- |
| `hypr/.config/hypr/scripts/bin-permissions.sh` | `bin/.local/bin/custom-bin-permissions.sh` | `custom-bin-permissions.sh` |
| `hypr/.config/hypr/scripts/keyboard-rgb.sh` | `bin/.local/bin/custom-keyboard-rgb.sh` | `custom-keyboard-rgb.sh` |
| `hypr/.config/hypr/scripts/project-open.sh` | `bin/.local/bin/custom-project-open.sh` | `custom-project-open.sh` |
| `hypr/.config/hypr/scripts/unified_menu.sh` | `bin/.local/bin/custom-unified-menu.sh` | `custom-unified-menu.sh` |
| `hypr/.config/hypr/scripts/vault-sync.sh` | `bin/.local/bin/custom-vault-sync.sh` | `custom-vault-sync.sh` |
| `bin/.local/bin/antigravity-launch` | `bin/.local/bin/custom-antigravity-launch` | `custom-antigravity-launch` |
| `bin/.local/bin/music-workspace` | `bin/.local/bin/custom-music-workspace` | `custom-music-workspace` |
| `bin/.local/bin/system-cleanup` | `bin/.local/bin/custom-system-cleanup` | `custom-system-cleanup` |

---

## 3. Step-by-Step: Safely Stowing Your Scripts

Always run `stow` commands from the root of your dotfiles repository (`~/dotfiles`).

### Step 1: Open Terminal & Navigate to Dotfiles
```bash
cd ~/dotfiles
```

### Step 2: Ensure All Scripts Have Executable Permissions
Before stowing, ensure the files in the repository have execution permissions:
```bash
chmod +x bin/.local/bin/*
```

### Step 3: Run a Safe Simulation (Dry-Run)
Use the `-n` (simulate) and `-v` (verbose) flags to preview what Stow will do **without modifying anything on disk**:

```bash
# Test restowing the bin package
stow -nvR bin

# Test restowing the hypr package
stow -nvR hypr
```

- If you see output like `LINK: .local/bin/custom-... -> ...`, Stow is ready and has found no conflicts.
- If you see `WARNING: cannot stow ...`, see the [Troubleshooting](#5-troubleshooting--conflict-resolution) section below before proceeding.

### Step 4: Apply the Symlinks (Restow)
The `-R` (restow) flag safely removes any outdated links for the package and creates new ones:

```bash
stow -R bin
stow -R hypr
```

> **Pro Tip**: To restow all packages at once:
> ```bash
> stow -R */
> ```

### Step 5: Verify the Symlinks
Check that the symlinks are correctly pointing into your dotfiles:

```bash
# Check ~/.local/bin symlinks
ls -la ~/.local/bin/custom-*

# Verify command discovery in PATH
which custom-unified-menu.sh
which custom-project-open.sh
```

---

## 4. Built-in Permission Checker (`custom-bin-permissions.sh`)

We have included a dedicated interactive helper `custom-bin-permissions.sh` to check and fix permissions on all your stowed binaries anytime:

```bash
custom-bin-permissions.sh
```

You can also launch this tool anytime from:
- **Scripts Menu** (`SUPER + ALT + Space`) $\rightarrow$ Select **"Bin Permissions"**.

---

## 5. Troubleshooting & Conflict Resolution

### Conflict 1: "Existing target is neither a link nor a directory"
**Cause**: A regular file already exists at `~/.local/bin/<filename>` before Stow had a chance to create the symlink.

**Solution**:
1. Check if you need to keep the file:
   ```bash
   # Inspect the existing file
   ls -l ~/.local/bin/<filename>
   ```
2. If it is an old duplicate, remove or backup the existing file:
   ```bash
   mv ~/.local/bin/<filename> ~/.local/bin/<filename>.bak
   ```
3. Run `stow -R bin` again.
4. (Optional) Alternatively, use Stow's adopt flag to adopt existing files into the repo:
   ```bash
   stow --adopt bin
   ```
   *(Caution: `--adopt` will overwrite the version in your repo with the one from your home directory).*

---

### Conflict 2: Stale / Dead Symlinks
**Cause**: If a file was renamed or deleted from a package, the old symlink in `~/.local/bin` or `~/.config/hypr` may become a broken link.

**Solution**:
1. Run restow to clean up stale links:
   ```bash
   stow -R bin
   stow -R hypr
   ```
2. If any broken symlinks remain, find and remove them:
   ```bash
   find ~/.local/bin -xtype l -delete
   ```

---

### Conflict 3: Clean Reset / Full Unstow
If you ever want to completely remove symlinks for a package and reinstall them freshly:

```bash
# Delete all symlinks created by bin
stow -D bin

# Re-link cleanly
stow bin
```

---

## 6. Quick Reference Cheat Sheet

| Command | Action | Description |
| :--- | :--- | :--- |
| `stow -nvR <pkg>` | **Dry-Run / Test** | Simulates restowing `<pkg>` verbosely without changing anything. |
| `stow -R <pkg>` | **Restow** | Refreshes and updates symlinks for `<pkg>`. |
| `stow <pkg>` | **Stow** | Creates symlinks for `<pkg>`. |
| `stow -D <pkg>` | **Unstow** | Removes all symlinks belonging to `<pkg>`. |
| `stow --adopt <pkg>` | **Adopt** | Links `<pkg>` and adopts existing target files into the repository. |
| `custom-bin-permissions.sh` | **Check Bins** | Interactive TUI to verify & fix `chmod +x` on stowed binaries. |

stow -v --no-folding bin - to stow a single or unstowed new bin file that has just added but hasnt been stowed