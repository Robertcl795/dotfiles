#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

install_starship() {
  log_step "Phase 4: Prompt themes (Starship)"

  if ! ensure_cmd starship; then
    log_info "Installing Starship via official installer."
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  fi

  select_theme
  local theme_dir="$DOTFILES_DIR/themes/$DOT_THEME"
  if [ ! -f "$theme_dir/starship.toml" ]; then
    log_warn "Theme $DOT_THEME not found, falling back to cyber."
    theme_dir="$DOTFILES_DIR/themes/cyber"
  fi

  symlink_with_backup "$theme_dir/starship.toml" "$HOME/.config/starship.toml"
  log_info "Starship theme set to $(basename "$theme_dir")."
}

if [ "${1:-}" = "--run" ]; then
  install_starship
fi
