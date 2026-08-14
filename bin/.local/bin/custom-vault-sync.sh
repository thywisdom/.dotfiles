#!/usr/bin/env bash
# custom-vault-sync.sh — Git-based Vault sync (push/pull/rebase)

set -euo pipefail

# Define primary vault directory
VAULT_DIR="$HOME/Documents/Knowledge-base"
# If primary not found, fall back to secondary location
if [[ ! -d "$VAULT_DIR" ]]; then
  FALLBACK_DIR="$HOME/Projects/Knowledge-base"
  if [[ -d "$FALLBACK_DIR" ]]; then
    VAULT_DIR="$FALLBACK_DIR"
  else
    notify-send -a "Vault Sync" -u critical "Vault directory not found in either location!"
    exit 1
  fi
fi

cd "$VAULT_DIR" || {
  notify-send -a "Vault Sync" -u critical "Sync Error" "Vault directory not found!"
  exit 1
}

notify-send -a "Vault Sync" -u low "Syncing..." "Checking for changes..." -t 2000

# 1. Stage all changes
git add .

# 2. Commit local changes if any exist
if git diff-index --quiet HEAD --; then
  LOCAL_COMMITTED=false
else
  git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
  LOCAL_COMMITTED=true
fi

# 3. Fetch remote safely
git fetch origin main || {
  notify-send -a "Vault Sync" -u critical "Network Error" "Failed to connect to remote."
  exit 1
}

LOCAL=$(git rev-parse @          2>/dev/null)
REMOTE=$(git rev-parse origin/main 2>/dev/null)
BASE=$(git merge-base  @ "$REMOTE"  2>/dev/null || echo "0")

if [ "$LOCAL" = "$REMOTE" ]; then
  # Already in sync
  if [ "$LOCAL_COMMITTED" = true ]; then
    git push origin main
    notify-send -a "Vault Sync" -u normal "Sync Complete" "Pushed new changes to remote."
  else
    notify-send -a "Vault Sync" -u low "Sync Complete" "Already up to date. No changes."
  fi

elif [ "$LOCAL" = "$BASE" ]; then
  # Local is behind — pull
  git pull --rebase origin main      && notify-send -a "Vault Sync" -u normal "Sync Complete" "Pulled new changes from remote." \
    || notify-send -a "Vault Sync" -u critical "Sync Error" "Failed to pull updates from remote!"

elif [ "$REMOTE" = "$BASE" ]; then
  # Remote is behind — push
  git push origin main      && notify-send -a "Vault Sync" -u normal "Sync Complete" "Pushed local updates to remote." \
    || notify-send -a "Vault Sync" -u critical "Sync Error" "Failed to push updates."

else
  # Diverged — rebase then push
  if git pull --rebase origin main; then
    git push origin main        && notify-send -a "Vault Sync" -u normal "Sync Complete" "Synchronized (pulled and pushed) changes." \
      || notify-send -a "Vault Sync" -u critical "Sync Error" "Failed to push updates after pulling."
  else
    notify-send -a "Vault Sync" -u critical "Sync Error" "Merge conflict detected! Manual intervention required."
  fi
fi
