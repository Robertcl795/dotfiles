#!/usr/bin/env bash
set -euo pipefail

# Dev stack (Phase 3): rustup / fnm / uv / AI CLIs must be reachable
# without restarting the WSL session.

# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require rustup
require cargo
require fnm
require uv
require claude
require opencode
require gh

rustup show >/dev/null
uv --version >/dev/null
fnm --version >/dev/null

if ! gh extension list 2>/dev/null | grep -q gh-copilot; then
  echo "[warn] gh-copilot extension not installed (requires 'gh auth login')." >&2
fi

echo "Dev stack OK."
