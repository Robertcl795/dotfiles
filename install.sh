#!/usr/bin/env bash
# install.sh - Main installation orchestrator

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"

# Load library modules
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/os_detect.sh"
source "$DOTFILES_DIR/lib/menu.sh"

# Load installer modules
source "$DOTFILES_DIR/installers/direnv.sh"
source "$DOTFILES_DIR/installers/mise.sh"
source "$DOTFILES_DIR/installers/docker.sh"
source "$DOTFILES_DIR/installers/k3d.sh"
source "$DOTFILES_DIR/installers/helm.sh"
source "$DOTFILES_DIR/installers/zsh.sh"
source "$DOTFILES_DIR/installers/modern_cli.sh"
source "$DOTFILES_DIR/installers/git.sh"

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║   Dotfiles Installation               ║"
    echo "║   WSL Development Environment         ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

setup_directories() {
    print_step "Creating directory structure..."
    ensure_dir "$HOME/.config"
    ensure_dir "$HOME/.local/bin"
    print_success "Directory structure created"
}

main() {
    show_banner
    detect_os
    select_tools
    
    echo
    print_header "Starting Installation"
    
    install_base_deps
    setup_directories
    
    install_direnv
    install_mise
    install_docker_tools
    install_k3d
    install_helm
    install_zsh
    install_modern_cli
    setup_git
    setup_mise_languages
    
    echo
    print_header "Installation Complete!"
    print_success "All selected tools installed!"
    echo
    print_info "Next steps:"
    echo "  1. Restart shell: exec zsh"
    echo "  2. Verify: mise doctor"
    echo
    print_success "Happy coding! 🚀"
}

main "$@"