#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

install_nvim() {
  log_step "Phase 5: Neovim"

  if ! ensure_cmd nvim; then
    case "${DOT_OS:-}" in
      ubuntu) sudo apt-get install -y neovim ;;
      arch) sudo pacman -S --noconfirm --needed neovim ;;
      *) die "Unknown OS for neovim install" ;;
    esac
  fi

  symlink_with_backup "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  log_info "Neovim config linked."
}

if [ "${1:-}" = "--run" ]; then
  install_nvim
fi
