#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for dotfiles installation
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash -s -- [--yes]
#   OR cloned: ./bootstrap.sh [--yes]

DOTFILES_REPO="https://github.com/Robertcl795/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
INSTALL_ARGS=()

# Colors (optional)
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info(){ echo -e "${BLUE}[INFO]${NC} $*" >&2; }
print_success(){ echo -e "${GREEN}[SUCCESS]${NC} $*" >&2; }
print_warning(){ echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
print_error(){ echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Basic arg pass-through (collect and forward to install.sh)
while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) INSTALL_ARGS+=("--yes"); shift ;;
    --install-dir) INSTALL_ARGS+=("--install-dir"); INSTALL_ARGS+=("$2"); shift 2 ;;
    --no-tty) INSTALL_ARGS+=("--no-tty"); shift ;;
    *) INSTALL_ARGS+=("$1"); shift ;;
  esac
done

# Prevent root
if [ "$(id -u)" -eq 0 ]; then
  print_error "Do not run this script as root. Clone and run as your regular user."
  exit 1
fi

print_info "Starting dotfiles bootstrap..."

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
if [ -d "$DOTFILES_DIR" ]; then
  print_info "Found existing $DOTFILES_DIR — pulling updates..."
  (cd "$DOTFILES_DIR" && git pull --rebase --autostash) || true
else
  print_info "Cloning dotfiles into $DOTFILES_DIR..."
  git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Export DOTFILES_DIR for child scripts and run installer forwarding args
export DOTFILES_DIR
cd "$DOTFILES_DIR"

# Ensure installer executable
chmod +x install.sh

# If piped from curl, we need to restore stdin from terminal for interactive prompts
# This is critical for making the menu work when running: curl ... | bash
if [ ! -t 0 ]; then
  print_info "Detected piped execution, restoring terminal for interactive prompts..."
  exec ./install.sh "${INSTALL_ARGS[@]}" </dev/tty
else
  # Execute installer normally
  exec ./install.sh "${INSTALL_ARGS[@]}"
fi
