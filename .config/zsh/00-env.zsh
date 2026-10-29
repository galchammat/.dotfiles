# PATH
path=(
  /opt/nvim/bin
  /usr/local/go/bin
  $HOME/.opencode/bin
  $HOME/go/bin
  $HOME/.local/bin
  $HOME/bin
  $path
)

export PATH

# Editor
export EDITOR=nvim
export VISUAL=nvim

# NVM base dir (do NOT load yet)
export NVM_DIR="$HOME/.nvm"

# GitHub Copilot CLI: enable the (experimental) extensions feature so the
# tmux-window-name extension can auto-rename the tmux window to the session name.
if [[ ":$COPILOT_CLI_ENABLED_FEATURE_FLAGS:" != *:EXTENSIONS:* ]]; then
  export COPILOT_CLI_ENABLED_FEATURE_FLAGS="${COPILOT_CLI_ENABLED_FEATURE_FLAGS:+$COPILOT_CLI_ENABLED_FEATURE_FLAGS,}EXTENSIONS"
fi
