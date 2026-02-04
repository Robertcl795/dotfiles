#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

install_zsh() {
  log_step "Phase 3: Shell setup (zsh)"

  if ! ensure_cmd zsh; then
    case "${DOT_OS:-}" in
      ubuntu) sudo apt-get install -y zsh ;;
      arch) sudo pacman -S --noconfirm --needed zsh ;;
      *) die "Unknown OS for zsh install" ;;
    esac
  fi

  local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
  if [ ! -d "$zinit_home" ]; then
    log_info "Installing zinit plugin manager."
    mkdir -p "$(dirname "$zinit_home")"
    git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
  fi

  if [ "$DOT_SHELL" = "zsh" ] && ensure_cmd chsh; then
    if [ "$DOT_NONINTERACTIVE" = "1" ]; then
      log_warn "Skipping default shell change in non-interactive mode."
    else
      if confirm "Set zsh as default shell?" "n"; then
        chsh -s "$(command -v zsh)" || log_warn "Unable to change default shell."
      fi
    fi
  fi
}

if [ "${1:-}" = "--run" ]; then
  install_zsh
fi
