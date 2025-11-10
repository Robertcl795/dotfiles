#!/usr/bin/env bash
# installer/direnv.sh - direnv installation

print_header "direnv Setup"

if ! command_exists direnv; then
    print_tool "direnv"
    print_step "Installing direnv..."
    
    if command_exists apt-get; then
        if install_tool "direnv" "sudo apt-get update && sudo apt-get install -y direnv"; then
            true  # Success
        else
            print_warning "Failed to install via apt, trying alternative method..."
            if install_tool "direnv" "curl -sfL https://direnv.net/install.sh | bash"; then
                export PATH="$HOME/.local/bin:$PATH"
            else
                print_error "Failed to install direnv"
                return 1
            fi
        fi
    elif command_exists pacman; then
        if ! install_tool "direnv" "sudo pacman -S --noconfirm direnv"; then
            print_error "Failed to install direnv"
            return 1
        fi
    else
        print_step "Installing from direnv.net..."
        if install_tool "direnv" "curl -sfL https://direnv.net/install.sh | bash"; then
            export PATH="$HOME/.local/bin:$PATH"
        else
            print_error "Failed to install direnv"
            return 1
        fi
    fi
else
    print_tool "direnv"
    print_success "Already installed"
fi

echo >&2
