# Rules
- all tasks must be idempotent
- use `stat` + `when` conditions for file/directory operations
- use `changed_when: false` for check commands
- handle failures gracefully with `failed_when` for expected error cases
- no interactive commands in unattended flows (use `--web`, tokens, or flags)
- handle package installations in the packages role as much as possible, and only verify that they exist in other roles that depend on packages.
- keep the git role toward the end because it is interactive. the only roles that should go after the git role are ones that rely on private repositories - so probably none ever. 

# Key Generation & Secrets
- SSH keys: check existence before generating, never overwrite
- GitHub tokens: source from ansible-vault or environment, never hardcode
- Hostname-based key comments for multi-machine tracking

# Testing
- Use `--check` mode for dry runs

# Package Management
- Pin critical package versions or document acceptable version ranges
- Use `state: present` not `state: latest` unless you explicitly want auto-updates
- Group packages by purpose (dev-tools, languages, desktop-apps)

