# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# ============================================
# PATH
# ============================================

export PATH="$HOME/.local/bin:$PATH"

# Java (managed by mise)
#export JAVA_HOME="$HOME/.local/share/mise/installs/java/26.0.1"
#export PATH="$JAVA_HOME/bin:$PATH"

# Go (uncomment if needed)
# export PATH="$PATH:$(go env GOPATH)/bin"

# CUDA (uncomment if needed)
# export PATH=/opt/cuda/bin:$PATH
# export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH

# ============================================
# ALIASES
# ============================================

# Utilities
alias vaultsync="${HOME}/.config/hypr/scripts/vault-sync.sh"
alias lg="lazygit"
alias ld="lazydocker"
alias cls="clear"
