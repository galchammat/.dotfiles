# ZTP Dev Environment

Personal dotfiles and workstation setup: an Ansible playbook for packages and
system configuration, and GNU stow for linking the config files themselves.

## How to use

Runs the complete setup from factory:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/galchammat/.dotfiles/main/bin/dotfiles)"
```

This clones the repository to `~/.dotfiles` over HTTPS, then runs the playbook.
HTTPS matters: the SSH key is generated and uploaded to GitHub by the `git`
role, which runs *after* the clone, so a fresh machine has no key to clone with
yet. Once the `git` role has run, the remote is switched to SSH automatically so
pushes are authenticated.

Install from a branch instead of `main`:

```bash
DOTFILES_BRANCH=my-branch bash -c "$(curl -fsSL .../bin/dotfiles)"
```

## Layout

```
.dotfiles/
├── ansible/          playbook, roles, inventory   (repo only)
├── bin/dotfiles      bootstrap + wrapper script   (repo only)
├── molecule/         container tests              (repo only)
└── stow/             the dotfiles themselves
    ├── nvim/.config/nvim/...
    ├── zsh/.zshenv, zsh/.config/zsh/...
    └── ...
```

Each directory under `stow/` is a package. The path of a file *inside* a
package is its path relative to `$HOME`, so
`stow/nvim/.config/nvim/init.lua` is linked to `~/.config/nvim/init.lua`.
Everything outside `stow/` stays in the repository and is never linked into the
home directory.

Packages are linked with `--no-folding`, so `~/.config` and friends stay real
directories and only leaf files are symlinks. This keeps files that tools write
next to their config (`lazy-lock.json`, `allowed_signers`, `hosts.yml`) out of
the git working tree.

## Common commands

```bash
dotfiles                      # full run
dotfiles -t stow              # only re-link the dotfiles
dotfiles --check              # dry run, changes nothing
dotfiles --clone-only         # fetch/update the repo, skip everything else
dotfiles --uninstall <role>   # run a role's uninstall script
```

Add a new config file by dropping it into the right package at its
`$HOME`-relative path and re-running `dotfiles -t stow`. Create a new package by
adding a directory under `stow/`; it is picked up automatically.

Skip packages that do not apply to a machine by setting `stow_exclude`, for
example on a headless box:

```yaml
stow_exclude: [hypr, i3, mako, rofi, alacritty, kitty, systemd, xdg-portal]
```

## Idempotency

All tasks in the playbook skip existing installs or configs. The `stow` role
reports `changed` only when a link is actually missing, stale or pointing
somewhere else.

Pre-existing real files that collide with a package are moved to
`~/.dotfiles-backup/` (preserving their relative path) before being replaced by
a symlink, so nothing is silently destroyed. Backups use `mv --backup=numbered`,
so a later conflict never overwrites an earlier backup.

Two legacy files are also moved aside, because they would silently defeat their
stowed XDG replacement: `~/.gitconfig` (git ignores `~/.config/git/config`
entirely whenever `~/.gitconfig` exists) and `~/.tmux.conf` (tmux loads it in
addition to the XDG file).

Links whose package file has since been deleted are removed, so the home
directory converges on exactly what the repo contains.

### Machine-generated settings

Ansible must never write *through* a symlink into the repo: that leaves the
working tree permanently dirty and breaks the next `git pull --ff-only`. So
generated settings go to files that are not part of any package:

| Written by | Goes to | Why it is safe |
|---|---|---|
| `git` role | `~/.config/git/config.local` | included from the stowed `config` |
| `git` role | `~/.config/git/allowed_signers` | not in any package |
| `nvm` role | `~/.bashrc` | not in any package |

`~/.config` and its subdirectories are real directories (`--no-folding`), so
creating a new file in them does not touch the repository.

## Neovim

Neovim is installed from the official prebuilt release rather than built from
source, which took 10-20 minutes and required a full toolchain. The tarball is
extracted to `/opt/nvim` (arch-independent, so the same `PATH` entry works on
x86_64 and arm64) and linked to `/usr/local/bin/nvim`.

The version is pinned in `ansible/roles/packages/defaults/main.yml`:

```yaml
neovim_version: "v0.12.5"
```

Change it and re-run `dotfiles -t packages` to upgrade or downgrade; the role
compares `nvim --version` against the pin and only downloads when they differ.
A machine still carrying the old source-built binary at `/usr/local/bin/nvim`
has it replaced by the symlink automatically.

Because nothing is compiled any more, `cmake`, `ninja-build` and `gettext` are
no longer installed. `gcc`/`gcc-c++`/`make` (Fedora) and `build-essential`
(Debian) stay, since nvim-treesitter and Mason compile at runtime.

## Testing

Two molecule scenarios run against Fedora containers under podman:

```bash
python3 -m venv .venv
.venv/bin/pip install molecule "molecule-plugins[podman]" ansible-core
.venv/bin/ansible-galaxy collection install containers.podman

.venv/bin/molecule test -s default     # stow role: linking + idempotence
.venv/bin/molecule test -s bootstrap   # bin/dotfiles clone on a bare machine
.venv/bin/molecule test -s packages    # package set + neovim install
```

`default` applies the `stow` role to a clean unprivileged user and asserts that
files are linked to the right places, that directories are not folded, that a
pre-existing `.zshrc` is backed up rather than clobbered, and that a second run
reports no changes.

`bootstrap` runs the real `bin/dotfiles` in a container with no SSH key, no
ssh-agent and no GitHub token. It exists because the clone happens in bash
before Ansible starts, so the `default` scenario cannot cover it.

`packages` installs the package set on a clean Fedora container and asserts that
every command the rest of the setup depends on resolves, and that Neovim matches
the pinned version and finds its runtime through the `/usr/local/bin` symlink.
It is separate from `default` because installing the full desktop package set is
slow, and the stow role needs to stay quick to iterate on.
## Migrating from the bare repository

Earlier versions cloned a bare repo to `~/.dotfiles.git` and checked it out
directly over `$HOME`. Running `dotfiles` now clones to `~/.dotfiles` and links
from `stow/`; your existing files are backed up to `~/.dotfiles-backup/` as they
are replaced by symlinks.

The old bare repo is left in place and the script points it out. Check it for
work that was never pushed, then remove it:

```bash
git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME log --branches --not --remotes
rm -rf $HOME/.dotfiles.git
```

Also remove the old copy of the command, which still targets the bare layout:

```bash
rm -f $HOME/bin/dotfiles
```

The `dotfiles` command now lives at `~/.local/bin/dotfiles` (a symlink to
`bin/dotfiles` in the repo), which is already on `PATH`.
