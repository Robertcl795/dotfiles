#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ "$DOT_VERBOSE" = "1" ]; then
  set -x
fi

if [ "$DOT_NONINTERACTIVE" != "1" ] && is_tty; then
  select_shell
  select_theme
  if [ -z "${DOT_ENABLE_K8S:-}" ]; then
    if confirm "Enable Kubernetes tooling (kubectl/helm/k3d)?" "y"; then
      DOT_ENABLE_K8S=1
    else
      DOT_ENABLE_K8S=0
    fi
  fi
else
  DOT_ENABLE_K8S="${DOT_ENABLE_K8S:-1}"
  select_shell
  select_theme
fi

export DOT_ENABLE_K8S

source "$DOTFILES_DIR/install/detect_os.sh"
detect_os

case "$DOT_OS" in
  ubuntu) bash "$DOTFILES_DIR/install/packages/ubuntu.sh" --run ;;
  arch) bash "$DOTFILES_DIR/install/packages/arch.sh" --run ;;
esac

bash "$DOTFILES_DIR/install/link.sh" --run

bash "$DOTFILES_DIR/install/shell/fish.sh" --run
bash "$DOTFILES_DIR/install/shell/zsh.sh" --run

bash "$DOTFILES_DIR/install/prompt/starship.sh" --run
bash "$DOTFILES_DIR/install/nvim.sh" --run
bash "$DOTFILES_DIR/install/dev/mise.sh" --run
bash "$DOTFILES_DIR/install/dev/k8s.sh" --run
bash "$DOTFILES_DIR/install/zellij.sh" --run
bash "$DOTFILES_DIR/install/dev/lang.sh" --run
bash "$DOTFILES_DIR/install/dev/ai.sh" --run
bash "$DOTFILES_DIR/install/wsl.sh" --run

if [ -d "$DOTFILES_DIR/tests" ]; then
  chmod +x "$DOTFILES_DIR/tests/"*.sh 2>/dev/null || true
fi

log_step "Bootstrap complete."
log_info "Run tests with: tests/99_smoke.sh"
