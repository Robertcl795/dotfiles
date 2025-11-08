#!/usr/bin/env bash
# lib/os_detect.sh - Operating system detection

detect_os() {
    print_step "Detecting operating system..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        print_error "Cannot detect OS"
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            export PKG_MANAGER="apt-get"
            export UPDATE_CMD="sudo apt-get update"
            export INSTALL_CMD="sudo apt-get install -y"
            export OS_TYPE="debian"
            ;;
        arch|manjaro)
            export PKG_MANAGER="pacman"
            export UPDATE_CMD="sudo pacman -Sy"
            export INSTALL_CMD="sudo pacman -S --noconfirm"
            export OS_TYPE="arch"
            ;;
        *)
            print_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    print_success "Detected: $OS ($OS_TYPE)"
}

install_base_deps() {
    print_step "Installing base dependencies..."
    $UPDATE_CMD

    case $OS_TYPE in
        debian)
            $INSTALL_CMD build-essential curl wget git unzip \
                software-properties-common ca-certificates gnupg lsb-release
            ;;
        arch)
            $INSTALL_CMD base-devel curl wget git unzip
            ;;
    esac
    
    print_success "Base dependencies installed"
}

export -f detect_os install_base_deps