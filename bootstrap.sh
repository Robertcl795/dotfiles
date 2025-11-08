#!/usr/bin/env bash
# Bootstrap script for dotfiles installation
# Usage: wget -qO- https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash

set -e

DOTFILES_REPO="https://github.com/Robertcl795/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if running in WSL
if ! grep -q microsoft /proc/version; then
    print_warning "This script is designed for WSL. Detected non-WSL environment."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_info "Starting dotfiles installation..."

# Install git if not present
if ! command -v git &> /dev/null; then
    print_info "Git not found. Installing git..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm git
    fi
fi

# Clone or update dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    print_info "Dotfiles directory exists. Updating..."
    cd "$DOTFILES_DIR"
    git pull
else
    print_info "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Run installer
chmod +x install.sh
./install.sh

print_success "Bootstrap complete! Restart your shell or run: source ~/.zshrc"