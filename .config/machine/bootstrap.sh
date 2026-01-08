#!/usr/bin/env bash
set -euo pipefail

MACHINE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/machine"
STAMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/machine"
STAMP_FILE="$STAMP_DIR/bootstrap.stamp"

mkdir -p "$STAMP_DIR"

log() { printf "\n==> %s\n" "$*"; }

# Run a sub-script if it exists + is executable
run_step() {
  local step="$1"
  local path="$MACHINE_DIR/$step"
  if [[ -x "$path" ]]; then
    log "Running $step"
    "$path"
  else
    log "Skipping $step (not found or not executable)"
  fi
}

# Optional: allow re-run with --force
FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

if [[ -f "$STAMP_FILE" && $FORCE -ne 1 ]]; then
  log "Bootstrap already ran on this machine. (stamp: $STAMP_FILE)"
  log "Run again with: bootstrap --force"
  exit 0
fi

log "Starting machine bootstrap from: $MACHINE_DIR"

run_step "apt.sh"
run_step "uefi.sh"
run_step "fonts.sh"

# Optional per-machine local hook (ignored by git)
if [[ -f "$MACHINE_DIR/local.sh" ]]; then
  log "Running local.sh (machine-specific)"
  bash "$MACHINE_DIR/local.sh"
fi

date -Is > "$STAMP_FILE"
log "Bootstrap complete. Stamp written to: $STAMP_FILE"

