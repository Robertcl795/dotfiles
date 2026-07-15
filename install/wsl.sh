#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DOT_ENABLE_WSLCONFIG="${DOT_ENABLE_WSLCONFIG:-1}"

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# Locate the Windows user profile dir (as a Linux path) via interop.
windows_userprofile() {
  local win_path=""
  if ensure_cmd wslvar; then
    win_path="$(wslvar USERPROFILE 2>/dev/null || true)"
  fi
  if [ -z "$win_path" ] && [ -x /mnt/c/Windows/System32/cmd.exe ]; then
    # Run from a Windows-accessible cwd to avoid UNC-path warnings
    win_path="$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r' || true)"
  fi
  if [ -z "$win_path" ]; then
    return 1
  fi
  wslpath -u "$win_path" 2>/dev/null
}

# Set key=value inside an INI section, preserving the rest of the file.
# Usage: set_ini_key <file> <section> <key> <value>
set_ini_key() {
  local file="$1" section="$2" key="$3" value="$4"
  if [ ! -f "$file" ]; then
    printf '[%s]\n%s=%s\n' "$section" "$key" "$value" > "$file"
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  awk -v section="$section" -v key="$key" -v value="$value" '
    BEGIN { in_section = 0; done = 0; seen_section = 0 }
    /^\[.*\]$/ {
      if (in_section && !done) { print key "=" value; done = 1 }
      in_section = (tolower($0) == "[" tolower(section) "]")
      if (in_section) seen_section = 1
      print
      next
    }
    {
      if (in_section && !done) {
        line = $0
        gsub(/[ \t]/, "", line)
        split(line, kv, "=")
        if (tolower(kv[1]) == tolower(key)) { print key "=" value; done = 1; next }
      }
      print
    }
    END {
      if (!seen_section) { print "[" section "]"; print key "=" value }
      else if (!done) { print key "=" value }
    }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

configure_wsl_conf() {
  log_info "Writing /etc/wsl.conf (systemd, interop, automount metadata)..."
  if [ -f /etc/wsl.conf ]; then
    sudo cp /etc/wsl.conf "/etc/wsl.conf.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  sudo tee /etc/wsl.conf > /dev/null << 'EOF'
# Managed by Robertcl795/dotfiles (install/wsl.sh)
# Apply with: wsl --shutdown (from PowerShell), then reopen the terminal.

[boot]
systemd=true

[network]
generateHosts=true
generateResolvConf=true

[interop]
enabled=true
appendWindowsPath=true

[automount]
enabled=true
root=/mnt/
# metadata enables Linux permissions on NTFS mounts
options="metadata,umask=22,fmask=11"
EOF
}

configure_wslconfig() {
  local profile wslconfig
  if ! profile="$(windows_userprofile)" || [ -z "$profile" ]; then
    log_warn "Could not locate the Windows user profile via interop; skipping .wslconfig."
    log_warn "Create %USERPROFILE%\\.wslconfig manually with: [wsl2] networkingMode=mirrored, dnsTunneling=true, autoProxy=true"
    return 0
  fi

  wslconfig="$profile/.wslconfig"
  log_info "Configuring $wslconfig (mirrored networking, DNS tunneling, auto proxy)..."

  if [ -f "$wslconfig" ]; then
    cp "$wslconfig" "${wslconfig}.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Existing .wslconfig backed up."
  fi

  set_ini_key "$wslconfig" "wsl2" "networkingMode" "mirrored"
  set_ini_key "$wslconfig" "wsl2" "dnsTunneling" "true"
  set_ini_key "$wslconfig" "wsl2" "autoProxy" "true"

  log_info ".wslconfig updated:"
  sed 's/^/    /' "$wslconfig" >&2

  log_warn "networkingMode=mirrored requires Windows 11 22H2+ (WSL falls back to NAT on older builds)."
}

check_filesystem_location() {
  case "$DOTFILES_DIR" in
    /mnt/*)
      log_warn "==============================================================="
      log_warn "PERFORMANCE WARNING: dotfiles live under $DOTFILES_DIR (NTFS)."
      log_warn "Cross-OS file I/O in WSL2 is 10-20x slower than the native"
      log_warn "ext4 filesystem. Move your projects to the Linux side, e.g.:"
      log_warn "  mv $DOTFILES_DIR ~/dotfiles"
      log_warn "==============================================================="
      ;;
  esac
  case "$PWD" in
    /mnt/*)
      log_warn "You are running from $PWD (Windows NTFS mount). Prefer ~/ for repos."
      ;;
  esac
}

configure_wsl() {
  log_step "Phase 10: WSL interop & networking optimizations"

  if ! is_wsl; then
    log_info "Not running under WSL; skipping WSL configuration."
    return 0
  fi

  if [ "$DOT_ENABLE_WSLCONFIG" != "1" ]; then
    log_info "WSL host configuration disabled (DOT_ENABLE_WSLCONFIG=0)."
    return 0
  fi

  configure_wsl_conf
  configure_wslconfig
  check_filesystem_location

  log_warn "Run 'wsl --shutdown' from PowerShell for network changes to take effect."
}

if [ "${1:-}" = "--run" ]; then
  configure_wsl
fi
