#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

install_packages_arch() {
  log_step "Phase 1: System update + base packages (Arch)"
  sudo pacman -Sy --noconfirm

  sudo pacman -S --noconfirm --needed \
    base-devel git curl wget unzip ca-certificates \
    ripgrep fd bat eza fzf zoxide neovim starship \
    tldr fish zsh

  log_info "Base packages installed."
}

if [ "${1:-}" = "--run" ]; then
  install_packages_arch
fi
