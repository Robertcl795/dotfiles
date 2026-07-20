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
    *) INSTALL_ARGS+=("$1"); shift ;;
  esac
done

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_arch() { grep -qi '^ID=arch' /etc/os-release 2>/dev/null; }

# ---------------------------------------------------------------------------
# Arch WSL first boot: a fresh archlinux WSL instance starts as root with no
# regular user. Provision the system, create a sudo-enabled user and set it
# as the WSL default, then ask for a restart before the real bootstrap runs.
# ---------------------------------------------------------------------------
arch_first_boot() {
  print_info "Fresh Arch WSL detected (running as root). Starting first-boot provisioning..."

  # Move out of the Windows filesystem (9P mounts are 10-20x slower)
  case "$PWD" in
    /mnt/*) print_info "Leaving Windows filesystem (cd /root)..."; cd /root ;;
  esac

  print_info "Updating system (pacman -Syu)..."
  pacman -Syu --noconfirm
  pacman -S --noconfirm --needed sudo

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
    print_info "Set a password for $username (needed for sudo):"
    passwd "$username" </dev/tty || print_warning "Password not set; run 'passwd $username' manually."
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

  print_success "First-boot provisioning complete."
  print_info "Now restart WSL from PowerShell:   wsl --shutdown"
  print_info "Reopen Arch (it will log in as $username) and run this bootstrap again."
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
