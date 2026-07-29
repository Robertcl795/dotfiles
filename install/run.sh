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

# One interactive screen decides everything: which tools, which shell, which
# theme. It writes the choice to ~/.config/rocker-dotfiles/selection.conf,
# which common.sh then loads for every phase (including standalone re-runs).
# Quitting the picker aborts before anything is installed.
bash "$DOTFILES_DIR/install/select.sh" --run || die "Installation cancelled."

# Pick the saved answer back up in this process (a DOT_TOOLS set in the
# environment still wins over what the picker wrote).
tools_reload_selection || die "Could not resolve the tool selection."
select_shell
select_theme

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
bash "$DOTFILES_DIR/install/dev/k8s.sh" --run
bash "$DOTFILES_DIR/install/zellij.sh" --run
bash "$DOTFILES_DIR/install/dev/lang.sh" --run
bash "$DOTFILES_DIR/install/dev/ai.sh" --run
bash "$DOTFILES_DIR/install/wsl.sh" --run
bash "$DOTFILES_DIR/install/ai.sh" --run
bash "$DOTFILES_DIR/install/fastfetch.sh" --run

if [ -d "$DOTFILES_DIR/tests" ]; then
  chmod +x "$DOTFILES_DIR/tests/"*.sh 2>/dev/null || true
fi

log_step "Bootstrap complete."
bash "$DOTFILES_DIR/install/summary.sh" --run
log_info "Run tests with: tests/99_smoke.sh"
