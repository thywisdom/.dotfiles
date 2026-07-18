# Package Management

Arch Linux package management, fully managed from the dotfiles repository.

## Repository Layout

```
dotfiles/
└── pkgmgmt/                              ← stow package  (stow pkgmgmt)
    └── .pkgmgmt/                         ← stows to ~/.pkgmgmt/
        ├── package.sh                    ← interactive setup script
        ├── packages/
        │   ├── pacman.txt                ← explicit official packages
        │   ├── aur.txt                   ← explicit AUR packages
        │   ├── pacman.d/
        │   │   └── ignore.conf           ← IgnorePkg source of truth
        │   └── README.md
        └── docs/
            └── package-management.md     ← this file
```

## Stow Behaviour

```bash
# From dotfiles root — creates ONE symlink:
#   ~/.pkgmgmt  →  dotfiles/pkgmgmt/.pkgmgmt
cd ~/dotfiles
stow pkgmgmt
```

Everything lands under `~/.pkgmgmt/` — no home directory pollution.

## System Integration Design

Two permanent `/etc/` modifications (done once by `package.sh configure`):

```
/etc/pacman.conf  [options]
   Include = /etc/pacman.d/dotfiles-ignore.conf
                      │
                      ▼ (symlink)
   ~/dotfiles/pkgmgmt/.pkgmgmt/packages/pacman.d/ignore.conf
```

All `IgnorePkg` and related directives live in `ignore.conf`, committed to git.
No further `/etc/` edits are needed after initial setup.

## Workflow

### Fresh install

```bash
git clone <repo> ~/dotfiles
# Option A — run directly
~/dotfiles/pkgmgmt/.pkgmgmt/package.sh configure

# Option B — stow first, then run
cd ~/dotfiles && stow pkgmgmt
~/.pkgmgmt/package.sh configure
```

`readlink -f` in the script resolves symlinks back to the real file in dotfiles,
so both invocation methods behave identically.

### Updating IgnorePkg

```bash
$EDITOR ~/dotfiles/pkgmgmt/.pkgmgmt/packages/pacman.d/ignore.conf

git add pkgmgmt/.pkgmgmt/packages/pacman.d/ignore.conf
git commit -m "packages: update IgnorePkg"
git push
```

No further action needed — pacman reads the symlink on every invocation.

## Usage & Commands

For a full list of commands and interactive TUI usage instructions, please see [usage.md](usage.md).

## Safety Guarantees

| Guarantee | How it's enforced |
|-----------|------------------|
| Never duplicate Include | `grep` check before insert |
| Never recreate valid symlink | `readlink -f` comparison |
| Never overwrite unrelated config | Insert-only; never rewrites file |
| Ask before replacing wrong symlink | Interactive confirmation prompt |
| Refuse to overwrite non-symlink | Exits with error message |
| Idempotent on repeated runs | All checks run before any action |
