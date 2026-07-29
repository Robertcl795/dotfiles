#!/usr/bin/env bash
set -euo pipefail

# Interactive tool picker — arrows to move, space to toggle, enter to install.
#
# Written against nothing but bash and ANSI escapes on purpose: this is the
# very first thing the bootstrap runs, before any package manager has been
# touched, so it cannot depend on fzf/gum/dialog being present. That also
# makes it identical on Arch, Ubuntu and anything else with a POSIX shell.
#
# Writes the result to ~/.config/rocker-dotfiles/selection.conf and exits 0.
# Exits 1 if the user quits, which aborts the bootstrap.

# Captured before common.sh runs: sourcing it resolves DOT_TOOLS to the
# registry defaults, after which an inherited value is indistinguishable
# from a defaulted one — and the picker would never open.
DOT_TOOLS_ENV="${DOT_TOOLS:-}"

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ---------------------------------------------------------------------------
# Terminal handling
# ---------------------------------------------------------------------------

if [ -n "${NO_COLOR:-}" ]; then
  C_RESET=""; C_BOLD=""; C_DIM=""; C_CYAN=""; C_MAGENTA=""; C_GREEN=""; C_YELLOW=""
else
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_CYAN=$'\033[36m'; C_MAGENTA=$'\033[35m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
fi

TUI_ACTIVE=0

tui_enter() {
  printf '\033[?1049h\033[?25l'   # alternate screen buffer, hide cursor
  TUI_ACTIVE=1
}

tui_leave() {
  [ "$TUI_ACTIVE" = "1" ] || return 0
  printf '\033[?25h\033[?1049l'   # show cursor, restore the main screen
  TUI_ACTIVE=0
}

# The alternate screen must be torn down on every exit path, including Ctrl+C
# and an unexpected error — otherwise the user is left with a hidden cursor.
trap 'tui_leave' EXIT
trap 'tui_leave; exit 130' INT TERM

term_rows() { printf '%s' "$(tput lines 2>/dev/null || echo 24)"; }
term_cols() { printf '%s' "$(tput cols 2>/dev/null || echo 80)"; }

# Read one keypress, normalised to a name. Escape sequences arrive as
# several bytes, so the first byte is read blocking and the rest with a
# short timeout (a bare Esc is then distinguishable from Esc-[-A).
read_key() {
  local k rest
  IFS= read -rsn1 k </dev/tty || { printf 'quit'; return 0; }
  case "$k" in
    '') printf 'enter' ;;
    ' ') printf 'space' ;;
    $'\033')
      rest=""
      IFS= read -rsn2 -t 0.05 rest </dev/tty 2>/dev/null || true
      case "$rest" in
        '[A') printf 'up' ;;
        '[B') printf 'down' ;;
        '[C') printf 'right' ;;
        '[D') printf 'left' ;;
        '') printf 'quit' ;;
        *) printf 'other' ;;
      esac
      ;;
    k|K) printf 'up' ;;
    j|J) printf 'down' ;;
    h|H) printf 'left' ;;
    l|L) printf 'right' ;;
    a) printf 'all' ;;
    n) printf 'none' ;;
    A) printf 'all_global' ;;
    N) printf 'none_global' ;;
    r|R) printf 'reset' ;;
    q|Q) printf 'quit' ;;
    *) printf 'other' ;;
  esac
}

# ---------------------------------------------------------------------------
# Row model
#
# ROWS holds one entry per printed line:
#   head|<category-id>   a section header (not selectable)
#   tool|<tool-id>       a checkbox
#   set|<setting-id>     a value cycled with left/right
# CURSOR indexes into ROWS and always lands on a selectable row.
# ---------------------------------------------------------------------------

ROWS=()
ROW_LABEL=()
ROW_DESC=()
CURSOR=0
SCROLL=0

# Labels and descriptions are resolved once, here, rather than in draw():
# every lookup costs a `cut` subprocess, and draw() runs on every keypress.
build_rows() {
  ROWS=(); ROW_LABEL=(); ROW_DESC=()
  local cat_row cat_id id set_row set_cat
  for cat_row in "${DOT_TOOL_CATEGORIES[@]}"; do
    cat_id="${cat_row%%|*}"
    ROWS+=("head|$cat_id")
    ROW_LABEL+=("$(printf '%s' "$cat_row" | cut -d'|' -f2)")
    ROW_DESC+=("$(printf '%s' "$cat_row" | cut -d'|' -f3)")

    for set_row in "${DOT_SETTING_REGISTRY[@]}"; do
      set_cat="$(printf '%s' "$set_row" | cut -d'|' -f2)"
      if [ "$set_cat" = "$cat_id" ]; then
        ROWS+=("set|${set_row%%|*}")
        ROW_LABEL+=("$(printf '%s' "$set_row" | cut -d'|' -f3)")
        ROW_DESC+=("$(printf '%s' "$set_row" | cut -d'|' -f4)")
      fi
    done

    for id in $(tool_ids_in_category "$cat_id"); do
      ROWS+=("tool|$id")
      ROW_LABEL+=("$(tool_field "$id" 3)")
      ROW_DESC+=("$(tool_field "$id" 4)")
    done
  done
}

row_kind() { printf '%s' "${1%%|*}"; }
row_id() { printf '%s' "${1#*|}"; }

row_selectable() {
  case "$(row_kind "$1")" in
    head) return 1 ;;
    *) return 0 ;;
  esac
}

# The category a row belongs to, for the "toggle this section" keys.
row_category() {
  local idx="$1" i kind
  for (( i = idx; i >= 0; i-- )); do
    kind="$(row_kind "${ROWS[$i]}")"
    if [ "$kind" = "head" ]; then
      row_id "${ROWS[$i]}"
      return 0
    fi
  done
  printf ''
}

cursor_to_first_selectable() {
  local i
  for (( i = 0; i < ${#ROWS[@]}; i++ )); do
    if row_selectable "${ROWS[$i]}"; then CURSOR=$i; return 0; fi
  done
  return 0
}

move_cursor() {
  local dir="$1" i
  if [ "$dir" = "down" ]; then
    for (( i = CURSOR + 1; i < ${#ROWS[@]}; i++ )); do
      if row_selectable "${ROWS[$i]}"; then CURSOR=$i; return 0; fi
    done
  else
    for (( i = CURSOR - 1; i >= 0; i-- )); do
      if row_selectable "${ROWS[$i]}"; then CURSOR=$i; return 0; fi
    done
  fi
  return 0
}

# ---------------------------------------------------------------------------
# Selection helpers
# ---------------------------------------------------------------------------

# Every mutating helper below ends in an explicit `return 0`. The script runs
# under `set -e`, and these are called straight from the key-dispatch `case`:
# a trailing test that happens to be false (e.g. "deselect all" over a section
# that is already empty) would otherwise return non-zero and kill the picker
# mid-session.

toggle_tool() {
  local id="$1"
  if tool_selected "$id"; then
    DOT_TOOLS="$(printf '%s' " $DOT_TOOLS " | sed "s/ $id / /g" | tr -s ' ')"
    DOT_TOOLS="${DOT_TOOLS# }"; DOT_TOOLS="${DOT_TOOLS% }"
  else
    DOT_TOOLS="${DOT_TOOLS:+$DOT_TOOLS }$id"
  fi
  return 0
}

set_category() {
  local cat="$1" want="$2" id
  for id in $(tool_ids_in_category "$cat"); do
    if [ "$want" = "1" ]; then
      tool_selected "$id" || DOT_TOOLS="${DOT_TOOLS:+$DOT_TOOLS }$id"
    else
      if tool_selected "$id"; then toggle_tool "$id"; fi
    fi
  done
  return 0
}

# Cycle a setting's value by ±1, wrapping at both ends.
cycle_setting() {
  local id="$1" dir="$2" row values cur i n vals=()
  for row in "${DOT_SETTING_REGISTRY[@]}"; do
    [ "${row%%|*}" = "$id" ] || continue
    values="$(printf '%s' "$row" | cut -d'|' -f5)"
    break
  done
  # shellcheck disable=SC2206
  vals=($values)
  n=${#vals[@]}
  cur="${!id:-${vals[0]}}"
  for (( i = 0; i < n; i++ )); do
    [ "${vals[$i]}" = "$cur" ] && break
  done
  [ "$i" -ge "$n" ] && i=0
  if [ "$dir" = "right" ]; then
    i=$(( (i + 1) % n ))
  else
    i=$(( (i - 1 + n) % n ))
  fi
  printf -v "$id" '%s' "${vals[$i]}"
  export "${id?}"
}

# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

HEADER_LINES=7
FOOTER_LINES=4

draw() {
  local rows cols body_height i row kind id label desc marker line
  rows="$(term_rows)"; cols="$(term_cols)"
  body_height=$(( rows - HEADER_LINES - FOOTER_LINES ))
  [ "$body_height" -lt 5 ] && body_height=5

  # Keep the cursor inside the viewport.
  if [ "$CURSOR" -lt "$SCROLL" ]; then
    SCROLL=$CURSOR
  elif [ "$CURSOR" -ge $(( SCROLL + body_height )) ]; then
    SCROLL=$(( CURSOR - body_height + 1 ))
  fi
  [ "$SCROLL" -lt 0 ] && SCROLL=0

  printf '\033[H\033[J'
  printf '\n'
  printf '  %s%sROCKER LABS%s %sDOTFILES%s\n' "$C_BOLD" "$C_MAGENTA" "$C_RESET" "$C_BOLD" "$C_RESET"
  printf '  %s%s%s\n' "$C_DIM" "$(printf '─%.0s' $(seq 1 $(( cols > 60 ? 58 : cols - 4 ))))" "$C_RESET"
  printf '  %sChoose what to install. Nothing is installed until you confirm.%s\n' "$C_DIM" "$C_RESET"
  printf '\n'
  printf '  %s↑↓%s move   %sspace%s toggle   %s←→%s change value   %sa%s/%sn%s section all/none\n' \
    "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET"
  printf '  %sA%s/%sN%s everything   %sr%s reset to defaults   %senter%s install   %sq%s quit\n' \
    "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_GREEN" "$C_RESET" "$C_YELLOW" "$C_RESET"

  for (( i = SCROLL; i < SCROLL + body_height && i < ${#ROWS[@]}; i++ )); do
    row="${ROWS[$i]}"
    kind="$(row_kind "$row")"
    id="$(row_id "$row")"

    if [ "$i" = "$CURSOR" ]; then marker="${C_CYAN}❯${C_RESET}"; else marker=" "; fi

    label="${ROW_LABEL[$i]}"
    desc="${ROW_DESC[$i]}"

    case "$kind" in
      head)
        printf ' %s   %s%s%s  %s%s%s\n' "" "$C_BOLD$C_MAGENTA" "$label" "$C_RESET" \
          "$C_DIM" "$desc" "$C_RESET"
        ;;
      tool)
        if tool_selected "$id"; then
          line="$(printf '%s[%s✓%s]%s %-22s %s%s%s' \
            "$C_GREEN" "$C_GREEN" "$C_GREEN" "$C_RESET" "$label" "$C_DIM" "$desc" "$C_RESET")"
        else
          line="$(printf '%s[ ]%s %s%-22s%s %s%s%s' \
            "$C_DIM" "$C_RESET" "$C_DIM" "$label" "$C_RESET" "$C_DIM" "$desc" "$C_RESET")"
        fi
        printf ' %s %s\n' "$marker" "$line"
        ;;
      set)
        printf ' %s %s‹%s %s%-9s%s %s›%s %-11s %s%s%s\n' \
          "$marker" "$C_CYAN" "$C_RESET" "$C_BOLD" "${!id:-}" "$C_RESET" "$C_CYAN" "$C_RESET" \
          "$label" "$C_DIM" "$desc" "$C_RESET"
        ;;
    esac
  done

  # Footer, pinned to the bottom of the screen.
  printf '\033[%d;1H' "$(( rows - 2 ))"
  printf '  %s%s%s\n' "$C_DIM" "$(printf '─%.0s' $(seq 1 $(( cols > 60 ? 58 : cols - 4 ))))" "$C_RESET"
  printf '  %s%s of %s tools selected%s' \
    "$C_BOLD" "$(tools_count_selected)" "$(tool_ids | wc -l | tr -d ' ')" "$C_RESET"
  if [ $(( ${#ROWS[@]} )) -gt "$body_height" ]; then
    printf '   %s(%s more below/above — keep scrolling)%s' "$C_DIM" "$(( ${#ROWS[@]} - body_height ))" "$C_RESET"
  fi
}

category_label() {
  local id="$1" row
  for row in "${DOT_TOOL_CATEGORIES[@]}"; do
    [ "${row%%|*}" = "$id" ] && { printf '%s' "$(printf '%s' "$row" | cut -d'|' -f2)"; return 0; }
  done
}

category_hint() {
  local id="$1" row
  for row in "${DOT_TOOL_CATEGORIES[@]}"; do
    [ "${row%%|*}" = "$id" ] && { printf '%s' "$(printf '%s' "$row" | cut -d'|' -f3)"; return 0; }
  done
}

setting_field() {
  local id="$1" idx="$2" row
  for row in "${DOT_SETTING_REGISTRY[@]}"; do
    [ "${row%%|*}" = "$id" ] && { printf '%s' "$(printf '%s' "$row" | cut -d'|' -f"$idx")"; return 0; }
  done
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------

run_picker() {
  # common.sh already resolved DOT_TOOLS (saved answer, else the registry
  # defaults, with DOT_ENABLE_K8S applied) — start from that.
  [ -n "${DOT_TOOLS:-}" ] || DOT_TOOLS="$(tools_default_selection)"
  [ -n "${DOT_SHELL:-}" ] || DOT_SHELL="zsh"
  [ -n "${DOT_THEME:-}" ] || DOT_THEME="default"

  build_rows
  cursor_to_first_selectable
  tui_enter

  local key row kind id
  while :; do
    draw
    key="$(read_key)"
    row="${ROWS[$CURSOR]}"
    kind="$(row_kind "$row")"
    id="$(row_id "$row")"

    case "$key" in
      up|down) move_cursor "$key" ;;
      space)
        case "$kind" in
          tool) toggle_tool "$id" ;;
          set) cycle_setting "$id" right ;;
        esac
        ;;
      left|right)
        [ "$kind" = "set" ] && cycle_setting "$id" "$key"
        ;;
      all) set_category "$(row_category "$CURSOR")" 1 ;;
      none) set_category "$(row_category "$CURSOR")" 0 ;;
      all_global) DOT_TOOLS="$(tools_all_ids)" ;;
      none_global) DOT_TOOLS="" ;;
      reset)
        DOT_TOOLS="$(tools_default_selection)"
        DOT_SHELL="zsh"; DOT_THEME="default"
        ;;
      enter) break ;;
      quit)
        tui_leave
        log_warn "Cancelled — nothing was installed."
        return 1
        ;;
    esac
  done

  tui_leave
  tools_apply_legacy_env
  tools_save_selection

  log_step "Selection saved to $(tools_selection_file)"
  print_selection_summary
  return 0
}

# Printed after the TUI exits, on the normal screen, so the choices stay
# visible in the scrollback while the install runs.
print_selection_summary() {
  local cat_row cat_id id line
  echo "" >&2
  for cat_row in "${DOT_TOOL_CATEGORIES[@]}"; do
    cat_id="${cat_row%%|*}"
    line=""
    for id in $(tool_ids_in_category "$cat_id"); do
      tool_selected "$id" && line="$line $id"
    done
    if [ -n "$line" ]; then
      printf '  %s%-12s%s%s\n' "$C_CYAN" "$(category_label "$cat_id")" "$C_RESET" "$line" >&2
    else
      printf '  %s%-12s%s%s(none)%s\n' "$C_CYAN" "$(category_label "$cat_id")" "$C_RESET" "$C_DIM" "$C_RESET" >&2
    fi
  done
  printf '  %s%-12s%s %s, theme %s\n' "$C_CYAN" "Settings" "$C_RESET" "$DOT_SHELL" "$DOT_THEME" >&2
  echo "" >&2
}

# Non-interactive fallback: resolve without drawing anything.
run_headless() {
  tools_resolve || return 1
  log_info "Tools: ${DOT_TOOLS:-（none）}"
  tools_save_selection
  return 0
}

if [ "${1:-}" = "--run" ]; then
  if [ "${DOT_NONINTERACTIVE:-0}" = "1" ] || ! is_tty || [ -n "$DOT_TOOLS_ENV" ]; then
    run_headless
  else
    run_picker
  fi
fi
