#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"

link_dotfiles() {
  log_step "Phase 2: Clone + link dotfiles"

  symlink_with_backup "$DOTFILES_DIR/shells/fish/config.fish" "$HOME/.config/fish/config.fish"
  symlink_with_backup "$DOTFILES_DIR/shells/fish/conf.d" "$HOME/.config/fish/conf.d"
  symlink_with_backup "$DOTFILES_DIR/shells/fish/functions" "$HOME/.config/fish/functions"

  symlink_with_backup "$DOTFILES_DIR/shells/zsh/zshrc" "$HOME/.zshrc"
  symlink_with_backup "$DOTFILES_DIR/shells/zsh" "$HOME/.config/zsh"

  symlink_with_backup "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  symlink_with_backup "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"

  log_info "Symlinks created."
}

if [ "${1:-}" = "--run" ]; then
  link_dotfiles
fi
