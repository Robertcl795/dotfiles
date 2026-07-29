#!/usr/bin/env bash
set -euo pipefail

# Tool-selection checkpoint: registry integrity and the resolution rules.
# Runs headless — the picker's own key handling needs a TTY and is not
# exercised here.

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

fail() { echo "$*" >&2; exit 1; }

# shellcheck source=install/common.sh
source "$DOTFILES_DIR/install/common.sh"

# ---- registry integrity -----------------------------------------------------

ids="$(tool_ids)"
dupes="$(printf '%s\n' "$ids" | sort | uniq -d)"
[ -z "$dupes" ] || fail "Duplicate tool ids in install/tools.sh: $dupes"

known_cats="$(printf '%s\n' "${DOT_TOOL_CATEGORIES[@]}" | cut -d'|' -f1)"
for row in "${DOT_TOOL_REGISTRY[@]}"; do
  id="${row%%|*}"
  fields="$(printf '%s' "$row" | awk -F'|' '{print NF}')"
  [ "$fields" = "8" ] || fail "Registry row for '$id' has $fields fields, expected 8."

  cat="$(printf '%s' "$row" | cut -d'|' -f2)"
  printf '%s\n' "$known_cats" | grep -qx "$cat" \
    || fail "Tool '$id' is in unknown category '$cat'."

  def="$(printf '%s' "$row" | cut -d'|' -f5)"
  case "$def" in 0|1) : ;; *) fail "Tool '$id' has a non-boolean default '$def'." ;; esac

  for col in 6 7 8; do
    pkg="$(printf '%s' "$row" | cut -d'|' -f"$col")"
    [ -n "$pkg" ] || fail "Tool '$id' has an empty package column $col (use - or x)."
  done
done

# Every category must actually contain something, or the picker draws an
# empty section.
for cat in $known_cats; do
  [ -n "$(tool_ids_in_category "$cat")" ] || fail "Category '$cat' has no tools."
done

# ---- resolution -------------------------------------------------------------

# Run against a scratch HOME so a real saved selection can't affect the test.
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT
export XDG_CONFIG_HOME="$TEST_HOME/.config"

DOT_TOOLS=""; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed with no input."
[ "$DOT_TOOLS_SOURCE" = "default" ] || fail "Expected the registry defaults, got '$DOT_TOOLS_SOURCE'."
[ -n "$DOT_TOOLS" ] || fail "Default selection is empty."

DOT_TOOLS="all"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed for 'all'."
[ "$(tools_count_selected)" = "$(tool_ids | wc -l | tr -d ' ')" ] \
  || fail "'all' did not select every tool."

DOT_TOOLS="none"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed for 'none'."
[ "$(tools_count_selected)" = "0" ] || fail "'none' left tools selected."

DOT_TOOLS="bat,eza,starship"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed for a comma list."
tool_selected bat || fail "bat should be selected."
tool_selected eza || fail "eza should be selected."
tool_selected neovim && fail "neovim should NOT be selected."

# A prefix must never match: `gh` is not selected by `github-cli`.
DOT_TOOLS="github-cli-not-a-real-id"; DOT_TOOLS_SOURCE=""
if tools_resolve 2>/dev/null; then
  fail "An unknown tool id was accepted."
fi

DOT_TOOLS="gh"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed for gh."
tool_selected gh || fail "gh should be selected."

# ---- package mapping --------------------------------------------------------

DOT_TOOLS="bat sshs claude"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed."
pkgs="$(tools_packages arch)"
[ "$pkgs" = "bat" ] || fail "arch packages should be just 'bat' (sshs/claude have no pacman package), got '$pkgs'."
pkgs="$(tools_packages ubuntu)"
[ "$pkgs" = "bat" ] || fail "ubuntu packages should be just 'bat', got '$pkgs'."

DOT_TOOLS="fd"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed."
[ "$(tools_packages ubuntu)" = "fd-find" ] || fail "fd should map to the apt name fd-find."
[ "$(tools_packages arch)" = "fd" ] || fail "fd should map to the pacman name fd."

# ---- legacy DOT_ENABLE_K8S --------------------------------------------------
#
# Only a user-supplied value steers the selection, which is why these set
# DOT_ENABLE_K8S_ENV (what tools.sh captures at source time) rather than the
# live DOT_ENABLE_K8S — that one is *derived* on every resolve, and feeding
# it back in would let a stale derivation override a fresh choice.

DOT_TOOLS="all"; DOT_TOOLS_SOURCE=""; DOT_ENABLE_K8S_ENV=0
tools_resolve || fail "tools_resolve failed."
any_tool_selected kubectl helm k3d && fail "DOT_ENABLE_K8S=0 must drop the k8s tools."

DOT_TOOLS="bat"; DOT_TOOLS_SOURCE=""; DOT_ENABLE_K8S_ENV=1
tools_resolve || fail "tools_resolve failed."
tool_selected kubectl || fail "DOT_ENABLE_K8S=1 must add the k8s tools."

DOT_TOOLS="bat"; DOT_TOOLS_SOURCE=""; DOT_ENABLE_K8S_ENV=""
tools_resolve || fail "tools_resolve failed."
[ "$DOT_ENABLE_K8S" = "0" ] || fail "DOT_ENABLE_K8S should be derived as 0 when no k8s tool is selected."

# The regression this guards: resolving twice in one process must not
# resurrect tools that were deselected in between (the derived
# DOT_ENABLE_K8S=1 from the first pass being read back as an instruction).
DOT_TOOLS="all"; DOT_TOOLS_SOURCE=""; DOT_ENABLE_K8S_ENV=""
tools_resolve || fail "tools_resolve failed."
[ "$DOT_ENABLE_K8S" = "1" ] || fail "DOT_ENABLE_K8S should be derived as 1 when k8s tools are selected."
DOT_TOOLS="bat eza"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed."
any_tool_selected kubectl helm k3d \
  && fail "A second resolve re-added the k8s tools from its own derived flag."

# ---- round trip through the saved file --------------------------------------

DOT_TOOLS="bat eza"; DOT_SHELL="fish"; DOT_THEME="tron"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed."
tools_save_selection
[ -f "$(tools_selection_file)" ] || fail "Selection file was not written."

DOT_TOOLS=""; DOT_SHELL=""; DOT_THEME=""; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed on reload."
[ "$DOT_TOOLS_SOURCE" = "file" ] || fail "Reload should have come from the file, got '$DOT_TOOLS_SOURCE'."
[ "$DOT_SHELL" = "fish" ] || fail "Saved shell did not survive the round trip."
[ "$DOT_THEME" = "tron" ] || fail "Saved theme did not survive the round trip."
tool_selected eza || fail "Saved tool list did not survive the round trip."

# An explicit env value still beats the saved file.
DOT_TOOLS="glow"; DOT_TOOLS_SOURCE=""
tools_resolve || fail "tools_resolve failed."
[ "$DOT_TOOLS_SOURCE" = "env" ] || fail "An explicit DOT_TOOLS must win over the saved file."
tool_selected eza && fail "The saved file overrode an explicit DOT_TOOLS."

# ---- the picker itself is at least syntactically sound ----------------------

bash -n "$DOTFILES_DIR/install/select.sh" || fail "install/select.sh has a syntax error."
