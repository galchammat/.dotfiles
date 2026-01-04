# If not interactive, return
[[ -o interactive ]] || return

# Load shared config (your additions live here)
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
