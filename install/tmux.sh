#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"
DOT_ENABLE_TMUX="${DOT_ENABLE_TMUX:-0}"

install_tmux() {
  if [ "$DOT_ENABLE_TMUX" != "1" ]; then
    log_info "tmux disabled (DOT_ENABLE_TMUX=0)."
    return 0
  fi
  log_step "Optional: tmux"
  if ensure_cmd tmux; then
    return 0
  fi
  case "${DOT_OS:-}" in
    ubuntu) sudo apt-get install -y tmux ;;
    arch) sudo pacman -S --noconfirm --needed tmux ;;
    *) die "Unknown OS for tmux install" ;;
  esac
}

if [ "${1:-}" = "--run" ]; then
  install_tmux
fi
