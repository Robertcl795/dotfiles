#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for dotfiles installation
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash
#   OR cloned: ./bootstrap.sh

DOTFILES_REPO="https://github.com/Robertcl795/dotfiles.git"
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

# Prevent root
if [ "$(id -u)" -eq 0 ]; then
  print_error "Do not run this script as root. Clone and run as your regular user."
  exit 1
fi

print_info "Starting dotfiles bootstrap..."

# WSL: warn early when installing onto the slow NTFS side
if grep -qi microsoft /proc/version 2>/dev/null; then
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
  print_info "Cloning dotfiles into $DOTFILES_DIR..."
  git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
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
