# Package Management Architecture

## Goal

Provide a reproducible, modular, Git-managed package management system for my Arch Linux / Omarchy setup.

The package configuration should live entirely inside my dotfiles repository.

The only permanent system modification should be:

- creating a symlink inside `/etc/pacman.d/`
- adding a single `Include` directive to `/etc/pacman.conf`

After the initial setup, all package management configuration should be maintained entirely from the dotfiles repository.

---

# Design Principles

- Single source of truth
- Idempotent setup scripts
- No manual editing of `/etc/pacman.conf`
- Compatible with Omarchy updates
- Compatible with pacman updates
- Easy to understand months later
- Easy for AI coding assistants to extend
- Modular
- Git friendly
- Follow Arch Linux conventions whenever possible

---

# Repository Layout

```text
dotfiles/

├── packages/
│   ├── pacman.txt
│   ├── aur.txt
│   ├── pacman.d/
│   │   └── ignore.conf
│   └── README.md
│
├── Setup/
│   ├── package.sh
│   ├── stow.sh
│   └── install.sh
│
└── docs/
    └── package-management.md
```

---

# Package Lists

## pacman.txt

Contains packages intentionally installed from official repositories.

Rules

- One package per line
- Comments allowed
- Human maintained
- Do not include dependencies

Example

```text
git
neovim
ghostty
docker
mpv
```

---

## aur.txt

Contains intentionally installed AUR packages.

Example

```text
vscodium-bin
zen-browser-bin
```

Rules

- One package per line
- Human maintained
- No dependencies

---

# Ignore Configuration

Location

```text
packages/pacman.d/ignore.conf
```

Contents

```ini
IgnorePkg = linux
IgnorePkg = linux-headers
IgnorePkg = hyprland
IgnorePkg = quickshell
```

This file is the single source of truth.

Future pacman directives may also live here.

Examples

```ini
NoUpgrade =
NoExtract =
```

---

# System Integration

The setup script performs two one-time operations.

## Step 1

Create a symlink.

```
/etc/pacman.d/dotfiles-ignore.conf
        │
        ▼
~/dotfiles/packages/pacman.d/ignore.conf
```

The symlink should always point to the current user's repository.

If the symlink already exists and points to the correct location, do nothing.

If it exists but points elsewhere, ask before replacing it.

---

## Step 2

Ensure `/etc/pacman.conf` contains

```ini
Include = /etc/pacman.d/dotfiles-ignore.conf
```

This Include must exist inside the `[options]` section.

Preferred insertion point:

Immediately before the first repository (`[core]`).

Example

Before

```ini
LocalFileSigLevel = Optional

[core]
```

After

```ini
LocalFileSigLevel = Optional

Include = /etc/pacman.d/dotfiles-ignore.conf

[core]
```

---

# package.sh

package.sh is an interactive setup utility.

Suggested menu

```
Package Setup

1. Install pacman packages
2. Install AUR packages
3. Install everything
4. Configure IgnorePkg
5. Verify configuration
6. Repair configuration
7. Exit
```

---

# Configure IgnorePkg

Responsibilities

Create the symlink.

Verify the symlink.

Insert Include if missing.

Never duplicate Include lines.

Never overwrite unrelated configuration.

---

# Verification

Verification checks

✓ pacman.conf exists

✓ Include exists

✓ symlink exists

✓ symlink target exists

✓ ignore.conf exists

✓ Include is inside [options]

Display

```
✓ Include configured

✓ Symlink valid

✓ Ignore configuration loaded
```

or

```
✗ Include missing

✗ Broken symlink
```

---

# Idempotency

Running package.sh repeatedly must never

- duplicate Include
- recreate valid symlink
- modify unrelated configuration

The script should safely report

```
Already configured.
```

when everything is correct.

---

# Installation

Official packages

```bash
sudo pacman -S --needed $(grep -vE '^\s*($|#)' pacman.txt)
```

AUR

```bash
paru -S --needed $(grep -vE '^\s*($|#)' aur.txt)
```

---

# Future Features

Possible future additions

- Export package lists
- Detect packages missing from configuration
- Compare installed vs desired packages
- Package categories
- Interactive installer
- Remove orphan packages
- Optional update wrapper
- Optional package search
- Optional backup of explicit package lists

---

# AI Development Rules

## Never

- Rewrite pacman.conf
- Hardcode usernames
- Duplicate Include lines
- Store IgnorePkg directly inside pacman.conf
- Delete unrelated configuration

---

## Always

- Preserve existing configuration
- Detect existing Include
- Detect existing symlink
- Validate symlink target
- Use idempotent operations
- Keep ignore.conf as the single source of truth

---

# Why This Design

Advantages

✓ Native pacman configuration

✓ Follows Arch conventions

✓ Git managed

✓ Omarchy compatible

✓ Portable

✓ Minimal

✓ Easy to extend

✓ AI friendly

✓ Single source of truth

✓ Future proof

✓ Only one permanent modification to pacman.conf

✓ No future edits to /etc are normally required

---

# Workflow

Fresh Install

↓

Clone dotfiles

↓

Run

```bash
./Setup/package.sh
```

↓

Install packages

↓

Create symlink

↓

Configure pacman Include

↓

Done

Whenever IgnorePkg changes

↓

Edit

```
packages/pacman.d/ignore.conf
```

↓

Commit

↓

Push

↓

Future machines automatically inherit the same IgnorePkg configuration after running package.sh.

No additional edits to `/etc/pacman.conf` should normally be required.


# Package Management Architecture

## Goal

Provide a reproducible, modular, Git-managed package management system for my Arch Linux / Omarchy setup.

The package configuration should live entirely inside my dotfiles repository.

The only permanent system modification should be:

- creating a symlink inside `/etc/pacman.d/`
- adding a single `Include` directive to `/etc/pacman.conf`

After the initial setup, all package management configuration should be maintained entirely from the dotfiles repository.

---

# Design Principles

- Single source of truth
- Idempotent setup scripts
- No manual editing of `/etc/pacman.conf`
- Compatible with Omarchy updates
- Compatible with pacman updates
- Easy to understand months later
- Easy for AI coding assistants to extend
- Modular
- Git friendly
- Follow Arch Linux conventions whenever possible

---

# Repository Layout

```text
dotfiles/

├── packages/
│   ├── pacman.txt
│   ├── aur.txt
│   ├── pacman.d/
│   │   └── ignore.conf
│   └── README.md
│
├── Setup/
│   ├── package.sh
│   ├── stow.sh
│   └── install.sh
│
└── docs/
    └── package-management.md
```

---

# Package Lists

## pacman.txt

Contains packages intentionally installed from official repositories.

Rules

- One package per line
- Comments allowed
- Human maintained
- Do not include dependencies

Example

```text
git
neovim
ghostty
docker
mpv
```

---

## aur.txt

Contains intentionally installed AUR packages.

Example

```text
vscodium-bin
zen-browser-bin
```

Rules

- One package per line
- Human maintained
- No dependencies

---

# Ignore Configuration

Location

```text
packages/pacman.d/ignore.conf
```

Contents

```ini
IgnorePkg = linux
IgnorePkg = linux-headers
IgnorePkg = hyprland
IgnorePkg = quickshell
```

This file is the single source of truth.

Future pacman directives may also live here.

Examples

```ini
NoUpgrade =
NoExtract =
```

---

# System Integration

The setup script performs two one-time operations.

## Step 1

Create a symlink.

```
/etc/pacman.d/dotfiles-ignore.conf
        │
        ▼
~/dotfiles/packages/pacman.d/ignore.conf
```

The symlink should always point to the current user's repository.

If the symlink already exists and points to the correct location, do nothing.

If it exists but points elsewhere, ask before replacing it.

---

## Step 2

Ensure `/etc/pacman.conf` contains

```ini
Include = /etc/pacman.d/dotfiles-ignore.conf
```

This Include must exist inside the `[options]` section.

Preferred insertion point:

Immediately before the first repository (`[core]`).

Example

Before

```ini
LocalFileSigLevel = Optional

[core]
```

After

```ini
LocalFileSigLevel = Optional

Include = /etc/pacman.d/dotfiles-ignore.conf

[core]
```

---

# package.sh

package.sh is an interactive setup utility.

Suggested menu

```
Package Setup

1. Install pacman packages
2. Install AUR packages
3. Install everything
4. Configure IgnorePkg
5. Verify configuration
6. Repair configuration
7. Exit
```

---

# Configure IgnorePkg

Responsibilities

Create the symlink.

Verify the symlink.

Insert Include if missing.

Never duplicate Include lines.

Never overwrite unrelated configuration.

---

# Verification

Verification checks

✓ pacman.conf exists

✓ Include exists

✓ symlink exists

✓ symlink target exists

✓ ignore.conf exists

✓ Include is inside [options]

Display

```
✓ Include configured

✓ Symlink valid

✓ Ignore configuration loaded
```

or

```
✗ Include missing

✗ Broken symlink
```

---

# Idempotency

Running package.sh repeatedly must never

- duplicate Include
- recreate valid symlink
- modify unrelated configuration

The script should safely report

```
Already configured.
```

when everything is correct.

---

# Installation

Official packages

```bash
sudo pacman -S --needed $(grep -vE '^\s*($|#)' pacman.txt)
```

AUR

```bash
paru -S --needed $(grep -vE '^\s*($|#)' aur.txt)
```

---

# Future Features

Possible future additions

- Export package lists
- Detect packages missing from configuration
- Compare installed vs desired packages
- Package categories
- Interactive installer
- Remove orphan packages
- Optional update wrapper
- Optional package search
- Optional backup of explicit package lists

---

# AI Development Rules

## Never

- Rewrite pacman.conf
- Hardcode usernames
- Duplicate Include lines
- Store IgnorePkg directly inside pacman.conf
- Delete unrelated configuration

---

## Always

- Preserve existing configuration
- Detect existing Include
- Detect existing symlink
- Validate symlink target
- Use idempotent operations
- Keep ignore.conf as the single source of truth

---

# Why This Design

Advantages

✓ Native pacman configuration

✓ Follows Arch conventions

✓ Git managed

✓ Omarchy compatible

✓ Portable

✓ Minimal

✓ Easy to extend

✓ AI friendly

✓ Single source of truth

✓ Future proof

✓ Only one permanent modification to pacman.conf

✓ No future edits to /etc are normally required

---

# Workflow

Fresh Install

↓

Clone dotfiles

↓

Run

```bash
./Setup/package.sh
```

↓

Install packages

↓

Create symlink

↓

Configure pacman Include

↓

Done

Whenever IgnorePkg changes

↓

Edit

```
packages/pacman.d/ignore.conf
```

↓

Commit

↓

Push

↓

Future machines automatically inherit the same IgnorePkg configuration after running package.sh.

No additional edits to `/etc/pacman.conf` should normally be required.