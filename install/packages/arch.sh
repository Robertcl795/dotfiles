#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

install_packages_arch() {
  log_step "Phase 1: System update + base packages (Arch)"

  if [ ! -d /etc/pacman.d/gnupg ] || ! sudo pacman-key --list-keys >/dev/null 2>&1; then
    log_info "Initializing pacman keyring..."
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
  fi

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
