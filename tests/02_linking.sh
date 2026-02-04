#!/usr/bin/env bash
set -euo pipefail

check_link() {
  if [ ! -L "$1" ]; then
    echo "Expected symlink: $1" >&2
    exit 1
  fi
}

check_link "$HOME/.config/nvim"
check_link "$HOME/.config/fish/config.fish"
check_link "$HOME/.zshrc"
check_link "$HOME/.config/mise/config.toml"
check_link "$HOME/.config/starship.toml"
