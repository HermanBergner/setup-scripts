# Feature 002 — Setup

## What it does

`setup/setup.sh` bootstraps a clean Arch Linux WSL instance into a fully configured development environment. It:

1. Installs `yay` (AUR helper) if not already present
2. Runs `scripts/install-packages.sh` to install all packages from the manifest
3. Clones the dotfiles repo to `~/dotfiles`
4. Symlinks `~/dotfiles/zsh/.zshrc` → `~/.zshrc`
5. Symlinks `~/dotfiles/nvim` → `~/.config/nvim`
6. Sets `zsh` as the default shell via `chsh`

The script is **idempotent** — safe to run multiple times on the same machine.

## Prerequisites

- Fresh Arch Linux WSL instance
- Internet access
- SSH key configured if `DOTFILES_REPO` is a private repository
- `manifest/packages.json` and `scripts/install-packages.sh` must exist (run `export/export.sh` on your existing machine first)

## Usage

```bash
export DOTFILES_REPO="https://github.com/youruser/dotfiles"
bash setup/setup.sh
```

Re-login or run `exec zsh` once setup completes.

## What gets set up

| Step | Action | Idempotency guard |
|------|--------|-------------------|
| Install yay | Clone + `makepkg -si` | Skipped if `command -v yay` succeeds |
| Install packages | Run `scripts/install-packages.sh` | `--needed` flag skips already-installed packages |
| Clone dotfiles | `git clone $DOTFILES_REPO ~/dotfiles` | Runs `git pull --ff-only` if already cloned |
| Link .zshrc | `ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc` | Skipped if symlink already points to correct target |
| Link nvim | `ln -s ~/dotfiles/nvim ~/.config/nvim` | Skipped if symlink already points to correct target |
| Set shell | `chsh -s /usr/bin/zsh` | Skipped if `$SHELL` already equals zsh path |

If a file already exists at a symlink target (e.g. `~/.zshrc`), the script backs it up to `.bak` before creating the symlink.

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DOTFILES_REPO` | Yes | Git URL of the dotfiles repository |

## Decisions

| Decision | Choice |
|----------|--------|
| AUR helper | `yay` (installed from AUR via `makepkg` if missing) |
| Dotfiles clone target | `~/dotfiles` |
| Root guard | Script exits if run as root (`$EUID -eq 0`) |
| Shell entry in /etc/shells | Auto-added if missing before `chsh` |
