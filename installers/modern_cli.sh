#!/usr/bin/env bash
# installers/modern_cli.sh

install_modern_cli() {
    if ! is_selected "modern_cli"; then return 0; fi
    print_step "Installing modern CLI tools..."

    case $OS_TYPE in
        debian) install_modern_cli_debian ;;
        arch) install_modern_cli_arch ;;
    esac

    print_success "Modern CLI tools installed"
}

install_modern_cli_debian() {
    $INSTALL_CMD fd-find ripgrep
    
    if ! command_exists bat; then
        wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
        sudo dpkg -i bat_0.24.0_amd64.deb
        rm bat_0.24.0_amd64.deb
    fi
    
    if ! command_exists eza; then
        wget -qc https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
        sudo chmod +x eza && sudo mv eza /usr/local/bin/
    fi
    
    if ! command_exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    if ! command_exists fzf; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi
}

install_modern_cli_arch() {
    $INSTALL_CMD bat eza fd ripgrep zoxide fzf
}

export -f install_modern_cli install_modern_cli_debian install_modern_cli_arch