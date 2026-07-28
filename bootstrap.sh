#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for dotfiles installation
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash
#   OR cloned: ./bootstrap.sh

DOTFILES_REPO="https://github.com/Robertcl795/dotfiles.git"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"

if [ -d "$SCRIPT_DIR/.git" ] || [ -d "$SCRIPT_DIR/install" ]; then
  DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
else
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
fi

INSTALL_ARGS=()

# Colors (optional)
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info(){ echo -e "${BLUE}[INFO]${NC} $*" >&2; }
print_success(){ echo -e "${GREEN}[SUCCESS]${NC} $*" >&2; }
print_warning(){ echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
print_error(){ echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Basic arg pass-through (collect and forward to install/run.sh)
while [ $# -gt 0 ]; do
  case "$1" in
    --noninteractive) export DOT_NONINTERACTIVE=1; shift ;;
    --shell) export DOT_SHELL="$2"; shift 2 ;;
    --theme) export DOT_THEME="$2"; shift 2 ;;
    --enable-k8s) export DOT_ENABLE_K8S=1; shift ;;
    --disable-k8s) export DOT_ENABLE_K8S=0; shift ;;
    --enable-tmux|--disable-tmux)
      print_warning "tmux support was replaced by Zellij; '$1' is deprecated and ignored."
      shift ;;
    --enable-wslconfig) export DOT_ENABLE_WSLCONFIG=1; shift ;;
    --disable-wslconfig) export DOT_ENABLE_WSLCONFIG=0; shift ;;
    --wsl-networking) export DOT_WSL_NETWORKING="$2"; shift 2 ;;
    *) INSTALL_ARGS+=("$1"); shift ;;
  esac
done

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_arch() { grep -qi '^ID=arch' /etc/os-release 2>/dev/null; }

# ---------------------------------------------------------------------------
# Arch WSL first boot: a fresh archlinux WSL instance starts as root with no
# regular user. Provision the system, create a sudo-enabled user and set it
# as the WSL default, then ask for a restart before the real bootstrap runs.
# A one-shot hook in the new user's ~/.bashrc resumes the bootstrap
# automatically on the first login after 'wsl --shutdown'.
# ---------------------------------------------------------------------------

# Ask for a password twice (hidden input) and set it via chpasswd.
# DOT_PASSWORD skips the prompt for non-interactive setups.
set_user_password() {
  local username="$1" pass="" confirm=""
  if [ -n "${DOT_PASSWORD:-}" ]; then
    if printf '%s:%s\n' "$username" "$DOT_PASSWORD" | chpasswd; then
      print_success "Password set for $username (from DOT_PASSWORD)."
    else
      print_warning "Password not set; run 'passwd $username' manually."
    fi
    return 0
  fi
  if [ ! -e /dev/tty ]; then
    print_warning "No terminal available; set a password later with 'passwd $username'."
    return 0
  fi
  print_info "Set a password for $username (needed for sudo):"
  while :; do
    read -r -s -p "  Password: " pass </dev/tty; echo >&2
    if [ -z "$pass" ]; then
      print_warning "Password cannot be empty; try again."
      continue
    fi
    read -r -s -p "  Confirm password: " confirm </dev/tty; echo >&2
    if [ "$pass" != "$confirm" ]; then
      print_warning "Passwords do not match; try again."
      continue
    fi
    break
  done
  if printf '%s:%s\n' "$username" "$pass" | chpasswd; then
    print_success "Password set for $username."
  else
    print_warning "Password not set; run 'passwd $username' manually."
  fi
  pass=""; confirm=""
}

arch_first_boot() {
  print_info "Fresh Arch WSL detected (running as root). Starting first-boot provisioning..."

  # Move out of the Windows filesystem (9P mounts are 10-20x slower)
  case "$PWD" in
    /mnt/*) print_info "Leaving Windows filesystem (cd /root)..."; cd /root ;;
  esac

  print_info "Updating system (pacman -Syu)..."
  pacman -Syu --noconfirm
  pacman -S --noconfirm --needed sudo git

  print_info "Granting sudo to the wheel group..."
  echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  chmod 440 /etc/sudoers.d/wheel

  local username="${DOT_USERNAME:-}"
  if [ -z "$username" ] && [ -e /dev/tty ]; then
    read -r -p "Username for your new (sudo-enabled) user: " username </dev/tty
  fi
  if [ -z "$username" ]; then
    print_error "No username provided. Re-run with DOT_USERNAME=<name> for non-interactive setups."
    exit 1
  fi

  if id "$username" >/dev/null 2>&1; then
    print_info "User $username already exists; ensuring wheel membership."
    usermod -aG wheel "$username"
  else
    useradd -m -G wheel -s /bin/bash "$username"
    set_user_password "$username"
  fi

  # Boot into this user (and systemd) by default from now on
  if [ -f /etc/wsl.conf ]; then
    cp /etc/wsl.conf "/etc/wsl.conf.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  cat > /etc/wsl.conf << EOF
[boot]
systemd=true

[user]
default=$username
EOF

  # -------------------------------------------------------------------------
  # Stage the repo and a one-shot resume hook so the bootstrap continues
  # automatically the first time $username logs in after the restart.
  # -------------------------------------------------------------------------
  local user_home staged
  user_home="$(getent passwd "$username" | cut -d: -f6)"
  user_home="${user_home:-/home/$username}"
  staged="$user_home/.dotfiles"

  if [ ! -d "$staged" ]; then
    if [ -d "$SCRIPT_DIR/.git" ] || [ -d "$SCRIPT_DIR/install" ]; then
      print_info "Staging dotfiles repo at $staged..."
      cp -a "$SCRIPT_DIR" "$staged"
    else
      print_info "Cloning dotfiles into $staged (branch: $DOTFILES_BRANCH)..."
      git clone --depth=1 --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$staged" \
        || print_warning "Clone failed; the resume hook will fetch the bootstrap itself."
    fi
  fi

  local var val
  {
    printf 'export DOTFILES_DIR=%q\n' "$staged"
    printf 'export DOTFILES_BRANCH=%q\n' "$DOTFILES_BRANCH"
    for var in DOT_SHELL DOT_THEME DOT_ENABLE_K8S DOT_ENABLE_WSLCONFIG DOT_WSL_NETWORKING DOT_NONINTERACTIVE DOT_VERBOSE; do
      val="$(printenv "$var" 2>/dev/null || true)"
      if [ -n "$val" ]; then
        printf 'export %s=%q\n' "$var" "$val"
      fi
    done
  } > "$user_home/.dotfiles-resume.env"

  touch "$user_home/.bashrc"
  if ! grep -q "dotfiles-bootstrap-resume" "$user_home/.bashrc"; then
    cat >> "$user_home/.bashrc" << 'RESUME_HOOK'

# >>> dotfiles-bootstrap-resume >>>
# One-shot hook written by bootstrap.sh first-boot provisioning.
# It removes itself after running once.
if [ -f "$HOME/.dotfiles-resume.env" ] && [ -t 0 ]; then
  . "$HOME/.dotfiles-resume.env"
  rm -f "$HOME/.dotfiles-resume.env"
  sed -i '/^# >>> dotfiles-bootstrap-resume >>>$/,/^# <<< dotfiles-bootstrap-resume <<<$/d' "$HOME/.bashrc"
  echo "Resuming dotfiles bootstrap..."
  if [ -f "${DOTFILES_DIR:-$HOME/.dotfiles}/bootstrap.sh" ]; then
    bash "${DOTFILES_DIR:-$HOME/.dotfiles}/bootstrap.sh"
  else
    curl -fsSL "https://raw.githubusercontent.com/Robertcl795/dotfiles/${DOTFILES_BRANCH:-main}/bootstrap.sh" | bash
  fi
fi
# <<< dotfiles-bootstrap-resume <<<
RESUME_HOOK
  fi
  chown -R "$username:" "$staged" 2>/dev/null || true
  chown "$username:" "$user_home/.bashrc" "$user_home/.dotfiles-resume.env"

  print_success "First-boot provisioning complete."
  print_info "WSL must now restart. When you reopen Arch it will log in as $username"
  print_info "and the bootstrap will continue automatically."

  local wsl_exe=""
  if command -v wsl.exe >/dev/null 2>&1; then
    wsl_exe="wsl.exe"
  elif [ -x /mnt/c/Windows/System32/wsl.exe ]; then
    wsl_exe="/mnt/c/Windows/System32/wsl.exe"
  fi

  if [ -n "$wsl_exe" ] && [ -e /dev/tty ] && [ "${DOT_NONINTERACTIVE:-0}" != "1" ]; then
    local reply=""
    read -r -p "Shut down WSL now? (Y/n) " reply </dev/tty
    case "$reply" in
      [Nn]*)
        print_info "Skipped. Run 'wsl --shutdown' from PowerShell when ready, then reopen Arch."
        ;;
      *)
        print_info "Shutting down WSL (this window will close)..."
        exec "$wsl_exe" --shutdown
        ;;
    esac
  else
    print_info "Now restart WSL from PowerShell:   wsl --shutdown"
    print_info "Then reopen Arch to continue the installation."
  fi
  exit 0
}

if [ "$(id -u)" -eq 0 ]; then
  if is_arch && is_wsl; then
    arch_first_boot
  fi
  print_error "Do not run this script as root. Clone and run as your regular user."
  exit 1
fi

print_info "Starting dotfiles bootstrap..."

# WSL: get off the Windows filesystem before doing anything else
if is_wsl; then
  case "$PWD" in
    /mnt/*)
      print_info "Running from a Windows NTFS mount ($PWD); moving to \$HOME."
      cd "$HOME"
      ;;
  esac
  case "$DOTFILES_DIR" in
    /mnt/*)
      print_warning "DOTFILES_DIR ($DOTFILES_DIR) is on a Windows NTFS mount."
      print_warning "WSL2 cross-OS I/O is 10-20x slower; install under ~/ instead (e.g. DOTFILES_DIR=\$HOME/.dotfiles)."
      ;;
  esac
fi

# Ensure git is present (install minimal if not)
if ! command -v git >/dev/null 2>&1; then
  print_info "git not found. Attempting to install git..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y git
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm git
  else
    print_error "No supported package manager found to install git. Aborting."
    exit 1
  fi
fi

# Clone or update repo
if [ -d "$DOTFILES_DIR/.git" ]; then
  print_info "Found existing $DOTFILES_DIR — pulling updates..."
  (cd "$DOTFILES_DIR" && git pull --rebase --autostash) || true
elif [ -d "$DOTFILES_DIR" ] && [ "$(ls -A "$DOTFILES_DIR" 2>/dev/null | wc -l)" -gt 0 ]; then
  print_warning "$DOTFILES_DIR exists and is not empty; using it without cloning."
else
  print_info "Cloning dotfiles into $DOTFILES_DIR (branch: $DOTFILES_BRANCH)..."
  git clone --depth=1 --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Export DOTFILES_DIR for child scripts and run installer forwarding args
export DOTFILES_DIR
cd "$DOTFILES_DIR"
chmod +x install/run.sh

# If piped from curl, we need to restore stdin from terminal for interactive prompts
# This is critical for making the menu work when running: curl ... | bash
if [ ! -t 0 ]; then
  print_info "Detected piped execution, restoring terminal for interactive prompts..."
  exec ./install/run.sh "${INSTALL_ARGS[@]}" </dev/tty
else
  exec ./install/run.sh "${INSTALL_ARGS[@]}"
fi
