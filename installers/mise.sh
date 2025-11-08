#!/usr/bin/env bash
# installers/mise.sh

install_mise() {
    if ! is_selected "mise"; then return 0; fi
    print_step "Installing mise..."
    
    if command_exists mise; then
        print_info "mise already installed"
        return 0
    fi

    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
    print_success "mise installed"
}

setup_mise_languages() {
    if ! is_selected "mise"; then return 0; fi
    print_step "Setting up development environments..."
    
    export PATH="$HOME/.local/bin:$PATH"
    
    print_info "Installing Node.js LTS..."
    mise use --global node@lts
    mise exec -- corepack enable
    
    print_info "Installing Python 3.12..."
    mise use --global python@3.12
    
    if confirm "Install Rust?"; then
        mise use --global rust@latest
    fi
    
    print_success "Development environments configured"
}

export -f install_mise setup_mise_languages