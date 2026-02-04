#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
cd "$DOTFILES_DIR"

if [ -x "$DOTFILES_DIR/install/run.sh" ]; then
  exec "$DOTFILES_DIR/install/run.sh" "$@"
else
  echo "install/run.sh not found. Please update your dotfiles repo." >&2
  exit 1
fi
