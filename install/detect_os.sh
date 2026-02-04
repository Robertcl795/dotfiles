#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"

detect_os() {
  log_step "Phase 0: Preflight & OS detection"

  if ! grep -qi microsoft /proc/version 2>/dev/null; then
    log_warn "Not running under WSL. This bootstrap targets WSL Arch/Ubuntu."
  fi

  if [ ! -f /etc/os-release ]; then
    die "Cannot detect OS: /etc/os-release not found."
  fi
  . /etc/os-release

  case "${ID:-}" in
    ubuntu)
      export DOT_OS="ubuntu"
      ;;
    arch)
      export DOT_OS="arch"
      ;;
    *)
      die "Unsupported OS: ${ID:-unknown}. Only WSL Ubuntu and WSL Arch are supported."
      ;;
  esac

  log_info "Detected OS: $DOT_OS"

  if ensure_cmd curl || ensure_cmd wget; then
    log_info "Network tools available."
  else
    die "Missing curl/wget. Please install one before continuing."
  fi

  if ! (curl -fsSL https://example.com >/dev/null 2>&1 || wget -qO- https://example.com >/dev/null 2>&1); then
    die "Network check failed. Please verify internet connectivity."
  fi

  if ! ensure_cmd sudo; then
    die "sudo is required for package installation."
  fi
}

if [ "${1:-}" = "--run" ]; then
  detect_os
fi
