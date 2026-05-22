# PATH
path=(
  /opt/nvim-linux-x86_64/bin
  /usr/local/go/bin
  /home/yog404/.opencode/bin
  $HOME/go/bin
  $HOME/.local/bin
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
export ANTHROPIC_VERTEX_PROJECT_ID=itpc-gcp-hcm-pe-eng-claude

