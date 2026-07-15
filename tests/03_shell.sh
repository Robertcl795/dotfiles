#!/usr/bin/env bash
set -euo pipefail

if ! command -v fish >/dev/null 2>&1; then
  echo "fish not installed." >&2
  exit 1
fi
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not installed." >&2
  exit 1
fi

fish -lc "echo ok" >/dev/null
zsh -lic "echo ok" >/dev/null

# radleylewis-based config must load its aliases and plugin loader
zsh -lic "type ll >/dev/null && type zplugin-update >/dev/null" \
  || { echo "zsh did not load the radleylewis base config." >&2; exit 1; }
