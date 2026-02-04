#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

install_mise() {
  log_step "Phase 6: Dev environment (mise)"

  if ! ensure_cmd mise; then
    log_info "Installing mise."
    curl -fsSL https://mise.jdx.dev/install.sh | sh
  fi

  mkdir -p "$HOME/.config/mise"
  symlink_with_backup "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"
}

if [ "${1:-}" = "--run" ]; then
  install_mise
fi
