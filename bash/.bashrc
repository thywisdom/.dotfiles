# If not running interactively, don't do anything (leave this at the top)
[[ $- != *i* ]] && return

# ============================================
# OMARCHY DEFAULTS
# (don't edit these directly — override below)
# ============================================

# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
fi

if [[ -d "$HOME/.local/share/omarchy" ]]; then
  export OMARCHY_PATH="$HOME/.local/share/omarchy"
elif [[ -d "/usr/share/omarchy" ]]; then
  export OMARCHY_PATH="/usr/share/omarchy"
fi

[[ -f "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"

# Force command hashing back on after Omarchy setup
set -h


# ============================================
# PATH
# ============================================

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:/home/suman/.lmstudio/bin"  # LM Studio CLI

# Java (managed by mise)
export JAVA_HOME="$HOME/.local/share/mise/installs/java/26.0.1"
export PATH="$JAVA_HOME/bin:$PATH"

# Go (uncomment if needed)
# export PATH="$PATH:$(go env GOPATH)/bin"

# CUDA (uncomment if needed)
# export PATH=/opt/cuda/bin:$PATH
# export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH


# ============================================
# NVM (Node Version Manager)
# ============================================

export NVM_DIR="$HOME/.config/nvm"
[[ -s "$NVM_DIR/nvm.sh" ]]          && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"


# ============================================
# ALIASES
# ============================================

# Workspace shortcuts (open language workspaces in Neovim)
alias javamind='cd /media/VAULT/workspace/Java  && nvim .'
alias cmind='cd /media/VAULT/workspace/C         && nvim .'
alias jsmind='cd /media/VAULT/workspace/JS       && nvim .'
alias rustmind='cd /media/VAULT/workspace/Rust   && nvim .'
alias pymind='cd /media/VAULT/workspace/Python   && nvim .'
alias dotmind='cd /media/VAULT/workspace/C#/     && nvim .'

# Utilities
alias obsync="$HOME/.config/hypr/scripts/obsync.sh"
alias lg="lazygit"
alias ld="lazydocker"
alias cls="clear"
