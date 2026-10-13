# PATH
path=(
  /opt/nvim/bin
  /usr/local/go/bin
  /home/yog404/.opencode/bin
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

# GCloud
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
# ANTHROPIC_VERTEX_PROJECT_ID is machine-local and deliberately untracked: set it
# in the "env" block of ~/.claude/settings.json (gitignored here). The value that
# used to live on this line was stale and was overridden by settings.json anyway.

# GitHub Copilot CLI: enable the (experimental) extensions feature so the
# tmux-window-name extension can auto-rename the tmux window to the session name.
if [[ ":$COPILOT_CLI_ENABLED_FEATURE_FLAGS:" != *:EXTENSIONS:* ]]; then
  export COPILOT_CLI_ENABLED_FEATURE_FLAGS="${COPILOT_CLI_ENABLED_FEATURE_FLAGS:+$COPILOT_CLI_ENABLED_FEATURE_FLAGS,}EXTENSIONS"
fi
