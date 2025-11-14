# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

alias javamind='cd /media/VAULT/workspace/Java && nvim .'
alias cmind='cd /media/VAULT/workspace/C && nvim .'
alias jsmind='cd /media/VAULT/workspace/JS && nvim .'
alias rustmind='cd /media/VAULT/workspace/Rust && nvim .'
alias pymind='cd /media/VAULT/workspace/Python && nvim .'



#obsidian sync
alias obsync="~/obsync.sh"
#
# Use VSCode instead of neovim as your default editor
# export EDITOR="code"
#
# Set a custom prompt with the directory revealed (alternatively use https://starship.rs)
# PS1="\W \[\e]0;\w\a\]$PS1"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Force command hashing back on after Omarchy setup
set -h


