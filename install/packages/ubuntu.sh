#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

install_packages_ubuntu() {
  log_step "Phase 1: System update + base packages (Ubuntu)"
  sudo apt-get update
  sudo apt-get install -y \
    build-essential git curl wget unzip ca-certificates \
    ripgrep fd-find bat \
    fzf zoxide neovim fish zsh

  if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y eza
  else
    sudo apt-get install -y exa
  fi

  if apt-cache show tldr >/dev/null 2>&1; then
    sudo apt-get install -y tldr
  else
    sudo apt-get install -y tealdeer || true
  fi

  if ! ensure_cmd starship; then
    log_info "Installing Starship via official installer."
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  fi

  if ensure_cmd fdfind && ! ensure_cmd fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if ensure_cmd batcat && ! ensure_cmd bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if ensure_cmd exa && ! ensure_cmd eza; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v exa)" "$HOME/.local/bin/eza"
  fi

  log_info "Base packages installed."
}

if [ "${1:-}" = "--run" ]; then
  install_packages_ubuntu
fi
