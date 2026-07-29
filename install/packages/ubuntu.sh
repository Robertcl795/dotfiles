#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

install_packages_ubuntu() {
  log_step "Phase 1: System update + base packages (Ubuntu)"
  sudo apt-get update

  # Always installed: the bootstrap itself needs these.
  sudo apt-get install -y \
    build-essential git curl wget unzip ca-certificates fish zsh

  # Everything else comes from the selection (install/tools.sh). apt aborts
  # the whole transaction when any one package has no installable candidate,
  # so a failed bulk install is retried package by package rather than
  # letting one missing candidate cost you the other twenty.
  local selected pkg
  selected="$(tools_packages ubuntu)"
  if [ -n "$selected" ]; then
    log_info "Installing selected packages: $selected"
    # shellcheck disable=SC2086
    if ! sudo apt-get install -y $selected; then
      log_warn "Bulk install failed; retrying one package at a time."
      for pkg in $selected; do
        sudo apt-get install -y "$pkg" || log_warn "apt could not install $pkg; continuing."
      done
    fi
  fi

  # Two packages have a differently-named fallback in older releases. Note
  # this is checked by *command*, never with `apt-cache show`: that can
  # report a package as present even when apt has no installable candidate
  # for the current release/arch, which used to produce a false positive and
  # take the whole bootstrap down under `set -e`.
  if tool_selected eza && ! ensure_cmd eza && ! ensure_cmd exa; then
    log_warn "eza has no installable candidate; trying exa instead."
    sudo apt-get install -y exa || log_warn "Neither eza nor exa is installable via apt; skipping."
  fi
  if tool_selected tldr && ! ensure_cmd tldr && ! ensure_cmd tealdeer; then
    log_warn "tldr has no installable candidate; trying tealdeer instead."
    sudo apt-get install -y tealdeer \
      || log_warn "Neither tldr nor tealdeer is installable via apt; skipping (cheat-sheet lookups won't be available)."
  fi

  if tool_selected starship && ! ensure_cmd starship; then
    log_info "Installing Starship via official installer."
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  fi

  if ensure_cmd fdfind && ! ensure_cmd fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if ensure_cmd batcat && ! ensure_cmd bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if ensure_cmd exa && ! ensure_cmd eza; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v exa)" "$HOME/.local/bin/eza"
  fi

  install_cli_extras_ubuntu

  log_info "Base packages installed."
}

# Core CLI extras. Ubuntu's apt archive lags behind Arch, so selected tools
# that apt can't provide come from GitHub release binaries instead (versions
# overridable via env).
install_cli_extras_ubuntu() {
  if ! any_tool_selected lazygit glow lazydocker zellij yazi sshs fastfetch duf; then
    return 0
  fi
  log_step "Core CLI extras (release binaries for what apt doesn't carry)"

  local arch rust_arch
  arch="$(detect_arch)"
  case "$arch" in
    arm64) rust_arch="aarch64" ;;
    *) rust_arch="x86_64" ;;
  esac

  local lazygit_ver="${DOT_LAZYGIT_VERSION:-0.44.1}"
  local glow_ver="${DOT_GLOW_VERSION:-2.1.0}"
  local lazydocker_ver="${DOT_LAZYDOCKER_VERSION:-0.24.1}"
  local goarch_suffix
  case "$arch" in
    arm64) goarch_suffix="Linux_arm64" ;;
    *) goarch_suffix="Linux_x86_64" ;;
  esac

  tool_selected lazygit && install_release_bin lazygit "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_ver}/lazygit_${lazygit_ver}_${goarch_suffix}.tar.gz"
  tool_selected glow && install_release_bin glow "https://github.com/charmbracelet/glow/releases/download/v${glow_ver}/glow_${glow_ver}_${goarch_suffix}.tar.gz"
  tool_selected lazydocker && install_release_bin lazydocker "https://github.com/jesseduffield/lazydocker/releases/download/v${lazydocker_ver}/lazydocker_${lazydocker_ver}_${goarch_suffix}.tar.gz"
  tool_selected zellij && install_release_bin zellij "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${rust_arch}-unknown-linux-musl.tar.gz"
  tool_selected yazi && install_release_bin yazi "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${rust_arch}-unknown-linux-gnu.zip"
  tool_selected sshs && install_release_bin sshs "https://github.com/quantumsheep/sshs/releases/latest/download/sshs-linux-${arch}"

  # fastfetch entered the Ubuntu archive in 24.10, so the bulk apt install
  # above already covers it there; older releases (including the LTS) fall
  # through to the upstream build.
  if tool_selected fastfetch && ! ensure_cmd fastfetch; then
    install_release_bin fastfetch "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch}.tar.gz"
  fi

  if tool_selected duf && ! ensure_cmd duf; then
    local duf_ver="${DOT_DUF_VERSION:-0.8.1}"
    install_release_bin duf "https://github.com/muesli/duf/releases/download/v${duf_ver}/duf_${duf_ver}_linux_${arch}.tar.gz"
  fi
  return 0
}

if [ "${1:-}" = "--run" ]; then
  install_packages_ubuntu
fi
