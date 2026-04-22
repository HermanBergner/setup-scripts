# Feature 002 — Setup

## What it does

`setup/setup.sh` bootstraps a clean Arch Linux WSL instance into a fully configured development environment. It:

1. Installs `yay` (AUR helper) if not already present
2. Runs `scripts/install-packages.sh` to install all packages from the manifest
3. Clones the dotfiles repo to `~/dotfiles`
4. Symlinks `~/dotfiles/zsh/.zshrc` → `~/.zshrc`
5. Symlinks `~/dotfiles/zsh/config` → `~/.config/zsh`
6. Clones zsh plugins (fzf-tab, zsh-syntax-highlighting, zsh-autosuggestions) into `~/.config/zsh/plugins/`
7. Symlinks `~/dotfiles/nvim` → `~/.config/nvim`
8. Sets `zsh` as the default shell via `usermod`

The script is **idempotent** — safe to run multiple times on the same machine.

## Prerequisites

- Fresh Arch Linux WSL instance
- Internet access
- `manifest/packages.json` and `scripts/install-packages.sh` must exist (run `export/export.sh` on your existing machine first)

## Usage

```bash
bash setup/setup.sh
```

Re-login or run `exec zsh` once setup completes. The dotfiles repo URL is hardcoded to `https://github.com/HermanBergner/dotfiles` and can be overridden with the `DOTFILES_REPO` env var if needed.

## What gets set up

| Step | Action | Idempotency guard |
|------|--------|-------------------|
| Install yay | Clone + `makepkg -si` | Skipped if `command -v yay` succeeds |
| Install packages | Run `scripts/install-packages.sh` | `--needed` flag skips already-installed packages |
| Clone dotfiles | `git clone $DOTFILES_REPO ~/dotfiles` | Runs `git pull --ff-only` if already cloned |
| Link .zshrc | `ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc` | Skipped if symlink already points to correct target |
| Link zsh config | `ln -s ~/dotfiles/zsh/config ~/.config/zsh` | Skipped if symlink already points to correct target |
| Install zsh plugins | Clone fzf-tab, zsh-syntax-highlighting, zsh-autosuggestions | Skipped if plugin dir already contains a `.git` folder |
| Link nvim | `ln -s ~/dotfiles/nvim ~/.config/nvim` | Skipped if symlink already points to correct target |
| Set shell | `sudo usermod -s /usr/bin/zsh $USER` | Skipped if `$SHELL` already equals zsh path |

If a file already exists at a symlink target, the script backs it up to `.bak` before creating the symlink.

## Environment variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DOTFILES_REPO` | No | `https://github.com/HermanBergner/dotfiles` | Git URL of the dotfiles repository |

## Decisions

| Decision | Choice |
|----------|--------|
| AUR helper | `yay` (installed from AUR via `makepkg` if missing) |
| Dotfiles clone target | `~/dotfiles` |
| Root guard | Script exits if run as root (`$EUID -eq 0`) |
| Shell change method | `sudo usermod -s` (avoids interactive password prompt from `chsh`) |
| zsh plugins | Cloned from upstream repos into `~/.config/zsh/plugins/` |
