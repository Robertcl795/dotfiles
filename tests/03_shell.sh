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

# Plugins (syntax highlighting, autosuggestions, etc.) must be present
plugdir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
for p in zsh-autosuggestions fast-syntax-highlighting zsh-history-substring-search zsh-vi-mode; do
  if [ ! -d "$plugdir/$p" ]; then
    echo "Missing zsh plugin: $p (expected in $plugdir)" >&2
    exit 1
  fi
done

# The default login shell should be zsh (unless fish was chosen)
if [ "${DOT_SHELL:-zsh}" = "zsh" ]; then
  login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  case "$login_shell" in
    */zsh) : ;;
    *) echo "Default shell is $login_shell, expected zsh." >&2; exit 1 ;;
  esac
fi
