#!/usr/bin/env bash
# Rocker Labs Dotfiles — tool registry — the single source of truth for what can be installed.
#
# Sourced by install/common.sh, so every phase script can ask
# `tool_selected <id>` before doing any work, and the interactive picker
# (install/select.sh) renders straight from this list.
#
# Registry row:
#   id|category|label|description|default|arch|ubuntu|scoop
#
# The three package columns hold the package name for that manager, or:
#   -   no package in that manager; a custom installer handles it
#   x   not available on that OS at all
#
# Base infrastructure (git, curl, zsh, fish, build tools) is deliberately
# absent: it is always installed, because the rest of the bootstrap needs it.

DOT_TOOL_CATEGORIES=(
  "cli|CLI stack|Modern replacements for the classic Unix tools"
  "prompt|Prompt|Shell prompt and colour theme"
  "editor|Editor|Neovim and its plugin manager"
  "lang|Languages|Toolchain managers"
  "k8s|Kubernetes|Local cluster tooling"
  "ai|AI tools|Agentic CLIs and the AI development standard"
)

DOT_TOOL_REGISTRY=(
  # ---- CLI stack ----
  "bat|cli|bat|cat with syntax highlighting and paging|1|bat|bat|bat"
  "eza|cli|eza|ls with icons, git status and tree mode|1|eza|eza|eza"
  "ripgrep|cli|ripgrep|grep that respects .gitignore, much faster|1|ripgrep|ripgrep|ripgrep"
  "fd|cli|fd|find with sane defaults|1|fd|fd-find|fd"
  "fzf|cli|fzf|fuzzy finder — history, files, completion|1|fzf|fzf|fzf"
  "zoxide|cli|zoxide|cd that learns the directories you use|1|zoxide|zoxide|zoxide"
  "duf|cli|duf|readable df|1|duf|duf|duf"
  "tldr|cli|tldr|example-first command help|1|tldr|tldr|x"
  "lazygit|cli|lazygit|full git TUI|1|lazygit|-|lazygit"
  "lazydocker|cli|lazydocker|container and log TUI|1|lazydocker|-|lazydocker"
  "yazi|cli|yazi|file manager that cd's you where you left off|1|yazi|-|yazi"
  "glow|cli|glow|render Markdown in the terminal|1|glow|-|glow"
  "lnav|cli|lnav|log navigator with parsing and filters|1|lnav|lnav|lnav"
  "sshs|cli|sshs|fuzzy picker over your ~/.ssh/config|1|-|-|-"
  "just|cli|just|per-project task runner|1|just|just|just"
  "zellij|cli|zellij|terminal multiplexer (replaces tmux)|1|zellij|-|zellij"
  "fastfetch|cli|fastfetch|greeting banner on every new shell|1|fastfetch|fastfetch|fastfetch"

  # ---- Prompt ----
  "starship|prompt|starship|cross-shell prompt, themed|1|starship|-|starship"

  # ---- Editor ----
  "neovim|editor|Neovim + lazy.nvim|editor, config and plugin manager|1|neovim|neovim|neovim"

  # ---- Languages ----
  "rustup|lang|rustup|Rust toolchain manager|1|rustup|-|rustup"
  "fnm|lang|fnm|Fast Node Manager, auto-switches on cd|1|-|-|fnm"
  "pnpm|lang|pnpm|Node package manager (standalone, needs fnm)|1|-|-|-"
  "uv|lang|uv|Python packages and environments|1|uv|-|uv"

  # ---- Kubernetes ----
  "kubectl|k8s|kubectl|Kubernetes CLI|1|-|-|kubectl"
  "helm|k8s|helm|chart package manager|1|-|-|helm"
  "k3d|k8s|k3d|local k3s clusters in Docker|1|-|-|k3d"

  # ---- AI ----
  "claude|ai|Claude Code|agentic coding CLI|1|-|-|-"
  "opencode|ai|opencode|open-source coding agent|1|-|-|-"
  "gh|ai|GitHub CLI + Copilot|gh, plus the gh-copilot extension|1|github-cli|gh|gh"
  "ai-standard|ai|AI dev standard|agents, prompts, skills, vector context DB|1|-|-|x"
)

# Settings the picker shows alongside the tools: a value cycled with ←/→
# rather than a checkbox.
#   id|category|label|description|values|default
DOT_SETTING_REGISTRY=(
  "DOT_SHELL|prompt|Login shell|which shell the bootstrap makes default|zsh fish|zsh"
  "DOT_THEME|prompt|Theme|prompt colours — see docs/THEMES.md|default tron cyber eva01 minimal|default"
)

# ---------------------------------------------------------------------------
# Registry queries
# ---------------------------------------------------------------------------

# tool_field <id> <index>  — 1=id 2=category 3=label 4=desc 5=default
#                            6=arch 7=ubuntu 8=scoop
tool_field() {
  local id="$1" idx="$2" row
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    case "$row" in
      "$id|"*)
        printf '%s' "$(printf '%s' "$row" | cut -d'|' -f"$idx")"
        return 0
        ;;
    esac
  done
  return 1
}

tool_ids() {
  local row
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    printf '%s\n' "${row%%|*}"
  done
}

tool_ids_in_category() {
  local cat="$1" row id rcat
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    id="${row%%|*}"
    rcat="$(printf '%s' "$row" | cut -d'|' -f2)"
    [ "$rcat" = "$cat" ] && printf '%s\n' "$id"
  done
  return 0
}

tool_exists() {
  local id="$1" row
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    [ "${row%%|*}" = "$id" ] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# Selection state
#
# DOT_TOOLS is a space-separated id list, kept space-padded internally so a
# substring test can never match a prefix (`gh` inside `github`).
# ---------------------------------------------------------------------------

tools_default_selection() {
  local row id def out=""
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    id="${row%%|*}"
    def="$(printf '%s' "$row" | cut -d'|' -f5)"
    [ "$def" = "1" ] && out="$out $id"
  done
  printf '%s' "${out# }"
}

tools_all_ids() {
  tool_ids | tr '\n' ' ' | sed 's/ $//'
}

# tool_selected <id> — the gate every phase script calls.
tool_selected() {
  local id="$1"
  case " ${DOT_TOOLS:-} " in
    *" $id "*) return 0 ;;
    *) return 1 ;;
  esac
}

# any_tool_selected <id>... — true if at least one is selected.
any_tool_selected() {
  local id
  for id in "$@"; do
    tool_selected "$id" && return 0
  done
  return 1
}

# tools_packages <arch|ubuntu|scoop> — package names for the selected tools
# that this manager can actually install.
tools_packages() {
  local mgr="$1" col row id pkg out=""
  case "$mgr" in
    arch) col=6 ;;
    ubuntu) col=7 ;;
    scoop) col=8 ;;
    *) return 1 ;;
  esac
  for row in "${DOT_TOOL_REGISTRY[@]}"; do
    id="${row%%|*}"
    tool_selected "$id" || continue
    pkg="$(printf '%s' "$row" | cut -d'|' -f"$col")"
    case "$pkg" in
      -|x|"") continue ;;
      *) out="$out $pkg" ;;
    esac
  done
  printf '%s' "${out# }"
}

tools_count_selected() {
  local id n=0
  for id in $(tool_ids); do
    tool_selected "$id" && n=$((n + 1))
  done
  printf '%s' "$n"
}

# ---------------------------------------------------------------------------
# Persistence
# ---------------------------------------------------------------------------

tools_selection_file() {
  printf '%s/rocker-dotfiles/selection.conf' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

tools_save_selection() {
  local file
  file="$(tools_selection_file)"
  mkdir -p "$(dirname "$file")"
  {
    echo "# Written by install/select.sh — edit freely, or re-run the picker."
    echo "# Delete this file to go back to the defaults in install/tools.sh."
    echo "DOT_SHELL=${DOT_SHELL:-zsh}"
    echo "DOT_THEME=${DOT_THEME:-default}"
    echo "DOT_TOOLS=\"${DOT_TOOLS:-}\""
  } > "$file"
}

# Load a saved selection without clobbering anything already set in the
# environment — an explicit DOT_TOOLS=... on the command line always wins.
tools_load_selection() {
  local file saved_shell="" saved_theme="" saved_tools=""
  file="$(tools_selection_file)"
  [ -f "$file" ] || return 1

  # Parsed by hand rather than sourced: this file lives outside the repo and
  # is never worth executing.
  while IFS= read -r line; do
    case "$line" in
      \#*|"") continue ;;
      DOT_SHELL=*) saved_shell="${line#DOT_SHELL=}" ;;
      DOT_THEME=*) saved_theme="${line#DOT_THEME=}" ;;
      DOT_TOOLS=*) saved_tools="${line#DOT_TOOLS=}" ;;
    esac
  done < "$file"

  saved_tools="${saved_tools%\"}"; saved_tools="${saved_tools#\"}"
  [ -z "${DOT_SHELL:-}" ] && [ -n "$saved_shell" ] && DOT_SHELL="$saved_shell"
  [ -z "${DOT_THEME:-}" ] && [ -n "$saved_theme" ] && DOT_THEME="$saved_theme"
  [ -z "${DOT_TOOLS:-}" ] && [ -n "$saved_tools" ] && DOT_TOOLS="$saved_tools"
  export DOT_SHELL DOT_THEME DOT_TOOLS
  return 0
}

# ---------------------------------------------------------------------------
# Resolution: env > saved file > registry defaults
# ---------------------------------------------------------------------------

# Expand the DOT_TOOLS the user passed in: `all`, `none`, or a
# comma/space-separated id list. Unknown ids are a hard error — a typo that
# silently skipped a tool would be discovered days later.
# Where the current DOT_TOOLS came from: env (explicit, wins over
# everything), file (a saved picker answer) or default (the registry).
DOT_TOOLS_SOURCE="${DOT_TOOLS_SOURCE:-}"

tools_resolve() {
  local requested="${DOT_TOOLS:-}" id unknown=""

  if [ -n "$requested" ]; then
    DOT_TOOLS_SOURCE="env"
  else
    if tools_load_selection >/dev/null 2>&1 && [ -n "${DOT_TOOLS:-}" ]; then
      DOT_TOOLS_SOURCE="file"
    else
      DOT_TOOLS_SOURCE="default"
    fi
    requested="${DOT_TOOLS:-}"
  fi

  case "$requested" in
    all) DOT_TOOLS="$(tools_all_ids)" ;;
    none) DOT_TOOLS="" ;;
    "") DOT_TOOLS="$(tools_default_selection)" ;;
    *)
      requested="$(printf '%s' "$requested" | tr ',' ' ')"
      for id in $requested; do
        tool_exists "$id" || unknown="$unknown $id"
      done
      if [ -n "$unknown" ]; then
        log_error "Unknown tool id(s):$unknown"
        log_error "Valid ids: $(tools_all_ids)"
        return 1
      fi
      DOT_TOOLS="$requested"
      ;;
  esac

  tools_apply_legacy_env
  export DOT_TOOLS
  return 0
}

# Re-read the selection file, discarding anything that was merely defaulted.
# run.sh calls this right after the picker writes its answer; an explicit
# DOT_TOOLS from the environment still wins.
tools_reload_selection() {
  [ "$DOT_TOOLS_SOURCE" = "env" ] && return 0
  DOT_TOOLS=""
  tools_resolve
}

# Captured once, at source time, and never overwritten: tools_apply_legacy_env
# *derives* DOT_ENABLE_K8S at the end of every resolve, so reading the live
# variable back as an instruction would make a second resolve in the same
# process re-add the very tools the picker just deselected. Only a value the
# user actually supplied counts as input. The `-` (not `:-`) keeps an
# explicit empty value distinguishable from an unset one.
DOT_ENABLE_K8S_ENV="${DOT_ENABLE_K8S_ENV-${DOT_ENABLE_K8S:-}}"

# DOT_ENABLE_K8S predates the picker and is still documented, so keep it
# authoritative when the user sets it explicitly.
tools_apply_legacy_env() {
  local id
  case "$DOT_ENABLE_K8S_ENV" in
    0)
      for id in kubectl helm k3d; do
        DOT_TOOLS="$(printf '%s' " $DOT_TOOLS " | sed "s/ $id / /g")"
      done
      DOT_TOOLS="$(printf '%s' "$DOT_TOOLS" | tr -s ' ')"
      DOT_TOOLS="${DOT_TOOLS# }"; DOT_TOOLS="${DOT_TOOLS% }"
      ;;
    1)
      for id in kubectl helm k3d; do
        tool_selected "$id" || DOT_TOOLS="$DOT_TOOLS $id"
      done
      DOT_TOOLS="${DOT_TOOLS# }"
      ;;
  esac

  # Keep the old flag in sync for anything still reading it.
  if any_tool_selected kubectl helm k3d; then
    DOT_ENABLE_K8S=1
  else
    DOT_ENABLE_K8S=0
  fi
  export DOT_ENABLE_K8S
}
