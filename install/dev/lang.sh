#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Language toolchain managers: rustup (Rust), fnm (Node.js), uv (Python).
# Everything lands in the current process PATH too, so later install steps
# (and the current WSL session) can use the tools without a re-login.

install_rustup() {
  if ! ensure_cmd rustup; then
    log_info "Installing rustup..."
    case "${DOT_OS:-}" in
      arch) sudo pacman -S --noconfirm --needed rustup ;;
      *) curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path ;;
    esac
  fi
  # shellcheck disable=SC1091
  [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
  export PATH="$HOME/.cargo/bin:$PATH"

  if ! rustup show active-toolchain >/dev/null 2>&1; then
    log_info "Installing stable Rust toolchain..."
    rustup default stable
  fi
  log_info "Rust: $(rustc --version 2>/dev/null || echo 'toolchain pending')"
}

install_fnm() {
  if ! ensure_cmd fnm; then
    log_info "Installing fnm (Fast Node Manager)..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/bin" --skip-shell \
      || { log_warn "fnm installer failed."; return 1; }
  fi
  export PATH="$HOME/.local/bin:$PATH"

  if ensure_cmd fnm && [ -z "$(fnm ls 2>/dev/null | grep -v system || true)" ]; then
    log_info "Installing Node.js LTS via fnm..."
    fnm install --lts || log_warn "Could not install Node LTS (network?); run 'fnm install --lts' later."
  fi
}

install_uv() {
  if ! ensure_cmd uv; then
    log_info "Installing uv (Python package/environment manager)..."
    case "${DOT_OS:-}" in
      arch) sudo pacman -S --noconfirm --needed uv ;;
      *) curl -fsSL https://astral.sh/uv/install.sh | sh ;;
    esac
  fi
  export PATH="$HOME/.local/bin:$PATH"
  log_info "uv: $(uv --version 2>/dev/null || echo 'not on PATH yet')"
}

install_lang_toolchains() {
  log_step "Phase 8: Language toolchains (rustup / fnm / uv)"
  install_rustup
  install_fnm
  install_uv
}

if [ "${1:-}" = "--run" ]; then
  install_lang_toolchains
fi
