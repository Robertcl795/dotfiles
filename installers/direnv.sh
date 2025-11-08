#!/usr/bin/env bash
# installers/direnv.sh

install_direnv() {
    if ! is_selected "direnv"; then return 0; fi
    print_step "Installing direnv..."
    
    if command_exists direnv; then
        print_info "direnv already installed"
        return 0
    fi

    $INSTALL_CMD direnv
    print_success "direnv installed"
}

export -f install_direnv