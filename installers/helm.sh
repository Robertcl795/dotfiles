#!/usr/bin/env bash
# installers/helm.sh

install_helm() {
    if ! is_selected "helm"; then return 0; fi
    print_step "Installing Helm..."
    
    if command_exists helm; then
        print_info "Helm already installed"
        return 0
    fi

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    print_success "Helm installed"
}

export -f install_helm