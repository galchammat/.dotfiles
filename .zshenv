ZSH_CONFIG="$HOME/.config/zsh"

for f in $ZSH_CONFIG/*.zsh; do
  source "$f"
done
