#!/bin/bash

# Install Modern Development Tools
# This script installs common modern CLI tools for development

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

# Update package list
print_status "Updating package list..."
sudo apt update

# Install basic tools
print_status "Installing basic development tools..."
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

print_success "Basic tools installed"

# Install modern CLI tools
print_status "Installing modern CLI tools..."

# eza (modern ls replacement)
if ! command -v eza &> /dev/null; then
    print_status "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
    print_success "eza installed"
else
    print_success "eza already installed"
fi

# bat (modern cat replacement)
if ! command -v bat &> /dev/null; then
    print_status "Installing bat..."
    sudo apt install -y bat
    # Create symlink as 'bat' might be installed as 'batcat' on some systems
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf $(which batcat) ~/.local/bin/bat
    fi
    print_success "bat installed"
else
    print_success "bat already installed"
fi

# ripgrep (modern grep replacement)
if ! command -v rg &> /dev/null; then
    print_status "Installing ripgrep..."
    sudo apt install -y ripgrep
    print_success "ripgrep installed"
else
    print_success "ripgrep already installed"
fi

# fd (modern find replacement)
if ! command -v fd &> /dev/null; then
    print_status "Installing fd..."
    sudo apt install -y fd-find
    # Create symlink
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd 2>/dev/null || true
    print_success "fd installed"
else
    print_success "fd already installed"
fi

# fzf (fuzzy finder)
if ! command -v fzf &> /dev/null; then
    print_status "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
    print_success "fzf installed"
else
    print_success "fzf already installed"
fi

# direnv (directory-based environment management)
if ! command -v direnv &> /dev/null; then
    print_status "Installing direnv..."
    sudo apt install -y direnv
    print_success "direnv installed"
else
    print_success "direnv already installed"
fi

# jq (JSON processor)
if ! command -v jq &> /dev/null; then
    print_status "Installing jq..."
    sudo apt install -y jq
    print_success "jq installed"
else
    print_success "jq already installed"
fi

# htop (process viewer)
if ! command -v htop &> /dev/null; then
    print_status "Installing htop..."
    sudo apt install -y htop
    print_success "htop installed"
else
    print_success "htop already installed"
fi

# ncdu (disk usage analyzer)
if ! command -v ncdu &> /dev/null; then
    print_status "Installing ncdu..."
    sudo apt install -y ncdu
    print_success "ncdu installed"
else
    print_success "ncdu already installed"
fi

# tldr (simplified man pages)
if ! command -v tldr &> /dev/null; then
    print_status "Installing tldr..."
    sudo apt install -y tldr
    print_success "tldr installed"
else
    print_success "tldr already installed"
fi

# Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed (you may need to log out and back in for group changes)"
else
    print_success "Docker already installed"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo apt install -y docker-compose-plugin
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

print_success "All development tools installed successfully!"
echo -e "${YELLOW}Note: Some tools may require a shell restart to work properly${NC}"
