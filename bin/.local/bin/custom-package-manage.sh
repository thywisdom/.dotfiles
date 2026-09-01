#!/usr/bin/env bash
# custom-package-manage.sh — Thin launcher for the dotfiles IgnorePkg manager.
# Resolves the stow-managed path first, falls back to the dotfiles source.
PKG_SCRIPT="${HOME}/.pkgmgmt/package.sh"
[[ -x "$PKG_SCRIPT" ]] || PKG_SCRIPT="${HOME}/dotfiles/pkgmgmt/.pkgmgmt/package.sh"
exec "$PKG_SCRIPT" "$@"
