#!/usr/bin/env bash
set -euo pipefail

# Sync/merge tooling for the vendored radleylewis configuration.
#
# The base zsh config under config/zsh/radleylewis/ is vendored from
# https://github.com/radleylewis/zsh and selected extras (alacritty) from
# https://github.com/radleylewis/dotfiles. This script re-fetches upstream
# and refreshes the files that are vendored verbatim. Files that carry
# local adaptations (core.zsh, aliases.zsh, plugins.zsh, prompt.zsh) are
# left in place and a diff against upstream is printed for manual merging.
#
# Usage:
#   install/shell/radleylewis.sh --run        # refresh verbatim files, show diffs
#   install/shell/radleylewis.sh --run --diff # only show diffs, change nothing

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

RL_ZSH_REPO="https://github.com/radleylewis/zsh.git"
RL_DOTFILES_REPO="https://github.com/radleylewis/dotfiles.git"
VENDOR_DIR="$DOTFILES_DIR/config/zsh/radleylewis"

# Vendored verbatim (safe to overwrite on sync)
VERBATIM_FILES=("bindings.zsh" "fzf.zsh")
# Vendored with local adaptations (diff only, merge by hand)
ADAPTED_FILES=("aliases.zsh" "plugins.zsh" "prompt.zsh")

sync_radleylewis() {
  local diff_only=0
  [ "${1:-}" = "--diff" ] && diff_only=1

  log_step "Syncing radleylewis upstream configuration"

  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  git clone --depth=1 "$RL_ZSH_REPO" "$tmp/zsh" || die "Could not clone $RL_ZSH_REPO"
  git clone --depth=1 "$RL_DOTFILES_REPO" "$tmp/dotfiles" || log_warn "Could not clone $RL_DOTFILES_REPO (skipping extras)."

  mkdir -p "$VENDOR_DIR"

  local f
  for f in "${VERBATIM_FILES[@]}"; do
    if [ ! -f "$tmp/zsh/$f" ]; then
      log_warn "Upstream no longer ships $f; keeping local copy."
      continue
    fi
    if [ "$diff_only" = "1" ]; then
      diff -u "$VENDOR_DIR/$f" <(sed "1i # Vendored from https://github.com/radleylewis/zsh ($f)\n" "$tmp/zsh/$f") || true
    else
      { echo "# Vendored from https://github.com/radleylewis/zsh ($f)"; echo; cat "$tmp/zsh/$f"; } > "$VENDOR_DIR/$f"
      log_info "Refreshed $f from upstream."
    fi
  done

  for f in "${ADAPTED_FILES[@]}"; do
    if [ -f "$tmp/zsh/$f" ] && [ -f "$VENDOR_DIR/$f" ]; then
      log_info "Diff against upstream for locally-adapted $f (merge manually):"
      diff -u "$tmp/zsh/$f" "$VENDOR_DIR/$f" || true
    fi
  done

  # Starship theme from radleylewis/zsh
  if [ -f "$tmp/zsh/starship.toml" ] && [ "$diff_only" != "1" ]; then
    mkdir -p "$DOTFILES_DIR/themes/radley"
    cp "$tmp/zsh/starship.toml" "$DOTFILES_DIR/themes/radley/starship.toml"
    log_info "Refreshed themes/radley/starship.toml."
  fi

  # Useful extras from radleylewis/dotfiles
  if [ -f "$tmp/dotfiles/.config/alacritty/alacritty.toml" ] && [ "$diff_only" != "1" ]; then
    mkdir -p "$DOTFILES_DIR/config/alacritty"
    cp "$tmp/dotfiles/.config/alacritty/alacritty.toml" "$DOTFILES_DIR/config/alacritty/alacritty.toml"
    log_info "Refreshed config/alacritty/alacritty.toml."
  fi

  log_info "Sync complete. Review changes with: git -C $DOTFILES_DIR diff"
}

if [ "${1:-}" = "--run" ]; then
  shift
  sync_radleylewis "${1:-}"
fi
