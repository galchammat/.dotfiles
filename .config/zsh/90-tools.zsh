# NVM: put the default node on PATH without sourcing nvm.sh.
#
# Sourcing nvm.sh costs about 1.5s on this machine, on every single shell,
# which was the bulk of startup time. For a normal shell all it achieves is
# prepending the default version's bin directory, so do that directly and
# leave the rest until nvm is actually used.
if [[ -d "$NVM_DIR/versions/node" ]]; then
  () {
    local target ref="$NVM_DIR/alias/default"
    local -i depth=0
    # default may point at an alias rather than a version, e.g.
    # default -> "lts/*" -> lts/krypton -> v24.19.0. Note the alias file is
    # literally named "lts/*", so every expansion here must stay quoted.
    while [[ -r "$ref" && depth -lt 5 ]]; do
      target="${$(<"$ref")%%$'\n'*}"
      [[ -n "$target" ]] || break
      if [[ -d "$NVM_DIR/versions/node/$target/bin" ]]; then
        path=("$NVM_DIR/versions/node/$target/bin" $path)
        return
      fi
      ref="$NVM_DIR/alias/$target"
      (( depth++ ))
    done
  }
fi

# nvm itself is only needed to switch or install versions, so load it on first
# use. The stub replaces itself with the real function.
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  nvm() {
    unset -f nvm
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

# SSH agent: share one agent between shells.
#
# This previously ran `eval $(ssh-agent -s)` whenever SSH_AUTH_SOCK was unset,
# so every shell started its own agent and none were ever reaped: three were
# still running here, the oldest for four days. Bind to a fixed socket and
# only start an agent when nothing is listening on it.
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  _ssh_agent_sock="${XDG_RUNTIME_DIR:-/tmp}/ssh-agent-${UID}.sock"
  # ssh-add exits 2 when it cannot reach an agent, 1 when the agent is up but
  # holds no identities. Only the former means we need to start one.
  SSH_AUTH_SOCK="$_ssh_agent_sock" ssh-add -l >/dev/null 2>&1
  if [[ $? -eq 2 ]]; then
    command rm -f "$_ssh_agent_sock"
    ssh-agent -s -a "$_ssh_agent_sock" >/dev/null 2>&1
  fi
  [[ -S "$_ssh_agent_sock" ]] && export SSH_AUTH_SOCK="$_ssh_agent_sock"
  unset _ssh_agent_sock
fi

# Add the key once, rather than on every shell.
if [[ -n "$SSH_AUTH_SOCK" && -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add -l 2>/dev/null | grep -q . || ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
fi
