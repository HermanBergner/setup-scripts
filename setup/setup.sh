#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/HermanBergner/dotfiles}"
DOTFILES_DIR="$HOME/dotfiles"
INSTALL_SCRIPT="$REPO_ROOT/scripts/install-packages.sh"

log() { echo "[setup] $*"; }

check_deps() {
  for cmd in git pacman chsh; do
    command -v "$cmd" &>/dev/null || { log "Missing dependency: $cmd"; exit 1; }
  done
}


install_yay() {
  if command -v yay &>/dev/null; then
    log "yay already installed, skipping."
    return
  fi

  log "Installing yay from AUR..."
  sudo pacman -S --needed --noconfirm base-devel git

  local yay_dir="/tmp/yay"
  if [[ ! -d "$yay_dir" ]]; then
    git clone https://aur.archlinux.org/yay.git "$yay_dir"
  fi

  (cd "$yay_dir" && makepkg -si --noconfirm)
  log "yay installed."
}

install_packages() {
  if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    log "Install script not found at $INSTALL_SCRIPT"
    log "Run export/export.sh on your existing machine first."
    exit 1
  fi

  if [[ ! -x "$INSTALL_SCRIPT" ]]; then
    log "Install script is not executable: $INSTALL_SCRIPT"
    exit 1
  fi

  log "Running install script..."
  bash "$INSTALL_SCRIPT"
}

clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    log "Dotfiles already cloned at $DOTFILES_DIR, pulling latest..."
    git -C "$DOTFILES_DIR" pull --ff-only || log "WARNING: dotfiles pull failed, using existing state."
  else
    log "Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

link_zshrc() {
  local src="$DOTFILES_DIR/zsh/.zshrc"
  local dst="$HOME/.zshrc"

  if [[ ! -f "$src" ]]; then
    log "WARNING: $src not found in dotfiles, skipping .zshrc link."
    return
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log ".zshrc already linked, skipping."
    return
  fi

  if [[ -e "$dst" ]]; then
    log "Backing up existing $dst to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  log "Linked $dst -> $src"
}

link_zsh_config() {
  local src="$DOTFILES_DIR/zsh/config"
  local dst="$HOME/.config/zsh"

  if [[ ! -d "$src" ]]; then
    log "WARNING: $src not found in dotfiles, skipping zsh config link."
    return
  fi

  mkdir -p "$HOME/.config"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "zsh config already linked, skipping."
    return
  fi

  if [[ -e "$dst" ]]; then
    log "Backing up existing $dst to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  log "Linked $dst -> $src"
}

link_nvim_config() {
  local src="$DOTFILES_DIR/nvim"
  local dst="$HOME/.config/nvim"

  if [[ ! -d "$src" ]]; then
    log "WARNING: $src not found in dotfiles, skipping nvim link."
    return
  fi

  mkdir -p "$HOME/.config"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "nvim config already linked, skipping."
    return
  fi

  if [[ -e "$dst" ]]; then
    log "Backing up existing $dst to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  log "Linked $dst -> $src"
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null || true)"

  if [[ -z "$zsh_path" ]]; then
    log "WARNING: zsh not found on PATH, skipping shell change."
    return
  fi

  if ! grep -qF "$zsh_path" /etc/shells 2>/dev/null; then
    log "Adding $zsh_path to /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
  fi

  if [[ "$SHELL" == "$zsh_path" ]]; then
    log "zsh is already the default shell."
    return
  fi

  sudo usermod -s "$zsh_path" "$USER"
  log "Default shell changed to $zsh_path. Re-login to take effect."
}

main() {
  if [[ "$EUID" -eq 0 ]]; then
    log "Do not run as root."
    exit 1
  fi

  check_deps
  install_yay
  install_packages
  clone_dotfiles
  link_zshrc
  link_zsh_config
  link_nvim_config
  set_default_shell

  log "Setup complete. Re-login or run 'exec zsh' to start using zsh."
}

main "$@"
