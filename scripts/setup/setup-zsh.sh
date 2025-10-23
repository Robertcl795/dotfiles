#!/bin/bash

# Setup ZSH with Oh-My-Zsh and Powerlevel10k
# This script installs and configures ZSH as the default shell

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if ZSH is already installed
if ! command -v zsh &> /dev/null; then
    print_status "Installing ZSH..."
    sudo apt update
    sudo apt install -y zsh
    print_success "ZSH installed successfully"
else
    print_success "ZSH is already installed"
fi

# Install Oh-My-Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_status "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-My-Zsh installed successfully"
else
    print_success "Oh-My-Zsh is already installed"
fi

# Install Powerlevel10k theme
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    print_status "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k installed successfully"
else
    print_success "Powerlevel10k is already installed"
fi

# Install zsh-autosuggestions plugin
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed successfully"
else
    print_success "zsh-autosuggestions is already installed"
fi

# Install zsh-syntax-highlighting plugin
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed successfully"
else
    print_success "zsh-syntax-highlighting is already installed"
fi

# Install zsh-completions plugin
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
    print_status "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
    print_success "zsh-completions installed successfully"
else
    print_success "zsh-completions is already installed"
fi

# Change default shell to ZSH
if [[ "$SHELL" != "$(which zsh)" ]]; then
    print_status "Setting ZSH as default shell..."
    chsh -s $(which zsh)
    print_success "Default shell changed to ZSH"
    echo -e "${YELLOW}Please log out and log back in for the shell change to take effect${NC}"
else
    print_success "ZSH is already the default shell"
fi

print_success "ZSH setup completed successfully!"
