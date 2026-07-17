# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
    source /etc/omarchy.conf
fi

if [[ -d "$HOME/.local/share/omarchy" ]]; then
    export OMARCHY_PATH="$HOME/.local/share/omarchy"
elif [[ -d "/usr/share/omarchy" ]]; then
    export OMARCHY_PATH="/usr/share/omarchy"
fi

[[ -f "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

alias javamind='cd /media/VAULT/workspace/Java && nvim .'
alias cmind='cd /media/VAULT/workspace/C && nvim .'
alias jsmind='cd /media/VAULT/workspace/JS && nvim .'
alias rustmind='cd /media/VAULT/workspace/Rust && nvim .'
alias pymind='cd /media/VAULT/workspace/Python && nvim .'
alias dotmind='cd /media/VAULT/workspace/C#/ && nvim .'


#obsidian sync
alias obsync="/home/suman/.config/hypr/scripts/obsync.sh"
alias lg="lazygit"
alias ld="lazydocker"
alias cls="clear"


# Set a custom prompt with the directory revealed (alternatively use https://starship.rs)
# PS1="\W \[\e]0;\w\a\]$PS1"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$PATH"# 

#Force command hashing back on after Omarchy setup
set -h


#export PATH="$PATH:$(go env GOPATH)/bin"
#export PATH=/opt/cuda/bin:$PATH
#export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH

export PATH="$PATH:$HOME/.dotnet/tools"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/suman/.lmstudio/bin"
# End of LM Studio CLI section


export JAVA_HOME="$HOME/.local/share/mise/installs/java/26.0.1"
export PATH="$JAVA_HOME/bin:$PATH"
