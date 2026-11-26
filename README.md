# Idempotent setup script

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/galchammat/.dotfiles/main/bin/dotfiles)"
```

## Upgrading OpenCode

Run `dotfiles --tags opencode` to migrate an existing npm install to OpenCode V2 and enable background updates on systemd. If you already use the Neovim integration, run `:Lazy update opencode.nvim` once to get the V2-compatible plugin.
