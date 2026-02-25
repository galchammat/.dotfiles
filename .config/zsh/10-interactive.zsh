# History
HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zsh_history"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

export GPG_TTY=$(tty)

# Vi mode
bindkey -v  # ok, this overrides OMZ keymaps if you want vi mode

# Aliases
alias dot='git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME'
alias bwu='export BW_SESSION="$(bw unlock --raw)"'
alias xc='xclip -selection clipboard'
