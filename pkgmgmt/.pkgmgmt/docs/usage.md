# Package Management Usage Guide

This utility manages your Arch Linux packages and `IgnorePkg` configurations elegantly via `stow`.

## Commands

Run the script interactively, or pass commands directly:

```bash
~/.pkgmgmt/package.sh [command]
```

| Command | Action |
|---------|--------|
| `install-pacman` | Installs explicitly defined official packages (`pacman.txt`). |
| `install-aur` | Installs explicitly defined AUR packages (`aur.txt`) using `yay` or `paru`. |
| `install-all` | Runs both package installations and integrates `ignore.conf`. |
| `configure` | Links `ignore.conf` into `/etc/pacman.conf`. |
| `verify` | Validates system integration health. |
| `repair` | Fixes missing symlinks or configuration safely. |
| `add-ignore` | Opens an interactive `fzf` TUI to pick installed packages to ignore. |

## Interactive Ignore TUI (`add-ignore`)

Easily prevent packages from upgrading without modifying files manually.

1. Run `~/.pkgmgmt/package.sh add-ignore`.
2. Scroll through your **explicitly installed** packages.
3. Use `alt-p` to toggle the preview window for package details.
4. Select one or more packages using `Tab`.
5. Press `Enter` to append them to `ignore.conf`.

The script safely deduplicates packages and ignores already ignored entries.

## Manual Updates

To manually ignore a package or keep a file unmodified:

1. Edit the file directly:
   ```bash
   $EDITOR ~/.pkgmgmt/packages/pacman.d/ignore.conf
   ```
2. Commit your changes to the dotfiles repository.

```ini
IgnorePkg = linux linux-headers
NoUpgrade = etc/passwd
```
