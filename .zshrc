# If not interactive, return
[[ -o interactive ]] || return

# Load shared config
[[ -f "$HOME/.shellrc" ]] && source "$HOME/.shellrc"

# History (reasonable defaults)
HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit
compinit

# Prompt (simple, readable)
PROMPT='%n@%m:%~$ '

# Path
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH=$PATH:/usr/local/go/bin
export PATH=/home/yog404/.opencode/bin:$PATH
export PATH=$PATH:$HOME/go/bin

# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
