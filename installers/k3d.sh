#!/usr/bin/env bash
# installers/k3d.sh

install_k3d() {
    if ! is_selected "k3d"; then return 0; fi
    print_step "Installing K3D..."
    
    if command_exists k3d; then
        print_info "K3D already installed"
        return 0
    fi

    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    print_success "K3D installed"
}

export -f install_k3d