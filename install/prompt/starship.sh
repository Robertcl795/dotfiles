#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

install_starship() {
  if ! tool_selected starship; then
    log_info "Phase 4: Starship not selected, skipping (your shell keeps its default prompt)."
    return 0
  fi
  log_step "Phase 4: Prompt themes (Starship)"

  if ! ensure_cmd starship; then
    log_info "Installing Starship via official installer."
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  fi

  select_theme
  local theme_file
  if [ "$DOT_THEME" = "default" ]; then
    theme_file="$DOTFILES_DIR/config/starship/starship.toml"
  else
    theme_file="$DOTFILES_DIR/themes/$DOT_THEME/starship.toml"
    if [ ! -f "$theme_file" ]; then
      log_warn "Theme $DOT_THEME not found, falling back to the default config."
      theme_file="$DOTFILES_DIR/config/starship/starship.toml"
    fi
  fi

  symlink_with_backup "$theme_file" "$HOME/.config/starship.toml"
  log_info "Starship config linked: $theme_file (theme: $DOT_THEME)"
}

if [ "${1:-}" = "--run" ]; then
  install_starship
fi
