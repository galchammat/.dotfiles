# NVM (lazy-ish load)
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

# SSH agent (only once per session)
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" >/dev/null
  [[ -f ~/.ssh/id_ed25519 ]] && ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

