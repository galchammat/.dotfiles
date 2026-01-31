# History
HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zsh_history"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Vi mode
bindkey -v  # ok, this overrides OMZ keymaps if you want vi mode

# Aliases
alias dot='git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME'

