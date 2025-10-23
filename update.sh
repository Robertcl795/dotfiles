#!/bin/bash

# Update Script for Dotfiles
# Pulls latest changes and re-installs dotfiles

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  $1"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

print_header "🔄 Updating Dotfiles"

# Check if dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Check if it's a git repository
if [[ ! -d ".git" ]]; then
    print_error "Dotfiles directory is not a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes in your dotfiles"
    read -p "Do you want to stash them before updating? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stashing changes..."
        git stash
    else
        print_error "Please commit or stash your changes before updating"
        exit 1
    fi
fi

# Pull latest changes
print_status "Pulling latest changes..."
git pull origin main || git pull origin master

print_success "Changes pulled successfully"

# Update Oh-My-Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_status "Updating Oh-My-Zsh..."
    cd "$HOME/.oh-my-zsh"
    git pull origin master
    cd "$DOTFILES_DIR"
    print_success "Oh-My-Zsh updated"
fi

# Update Powerlevel10k
if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    print_status "Updating Powerlevel10k..."
    cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git pull
    cd "$DOTFILES_DIR"
    print_success "Powerlevel10k updated"
fi

# Update plugins
PLUGINS=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "zsh-completions"
)

for plugin in "${PLUGINS[@]}"; do
    PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
    if [[ -d "$PLUGIN_DIR" ]]; then
        print_status "Updating $plugin..."
        cd "$PLUGIN_DIR"
        git pull
        cd "$DOTFILES_DIR"
        print_success "$plugin updated"
    fi
done

# Re-run installation script
print_status "Re-installing dotfiles..."
bash "$DOTFILES_DIR/install.sh"

print_success "Dotfiles updated successfully!"

# Reload shell configuration
if [[ -n "$ZSH_VERSION" ]]; then
    print_status "Reloading ZSH configuration..."
    source "$HOME/.zshrc"
fi

print_header "✨ Update Complete"
echo -e "${GREEN}Your dotfiles are now up to date!${NC}"
echo -e "${YELLOW}You may need to restart your terminal for all changes to take effect.${NC}"
