#!/usr/bin/env bash
# installers/docker.sh

install_docker_tools() {
    if ! is_selected "docker"; then return 0; fi
    print_step "Setting up Docker tools..."
    
    if command_exists docker; then
        print_info "Docker already accessible"
    else
        print_warning "Docker not found. Install Docker Desktop with WSL2 backend"
        print_info "Visit: https://docs.docker.com/desktop/windows/wsl/"
    fi

    if ! command_exists docker-compose; then
        $INSTALL_CMD docker-compose
    fi
    
    print_success "Docker tools configured"
}

export -f install_docker_tools