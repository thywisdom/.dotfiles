#!/bin/bash

# Set the Vault Directory
VAULT_DIR="/home/suman/Desktop/Knowledge-base"

# Navigate to the Vault Directory
cd "$VAULT_DIR" || { echo "Vault directory not found!"; exit 1; }

# Pull the latest changes first
echo "🔄 Pulling latest updates..."
git pull --rebase origin main || { 
    echo "❌ Pull failed! Stashing changes and retrying...";
    git stash && git pull --rebase origin main && git stash pop
}

# Add all changes
git add .

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo "✅ No new changes to commit. Already up to date."
else
    # Commit with a timestamp
    COMMIT_MESSAGE="Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MESSAGE"
    
    # Push changes
    echo "🚀 Pushing changes..."
    git push origin main || { echo "❌ Push failed! Check your connection."; exit 1; }
    echo "✅ Sync complete!"
fi
