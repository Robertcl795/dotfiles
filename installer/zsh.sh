#!/usr/bin/env bash
# installer/zsh.sh - Zsh and Zinit installation

print_header "Zsh Shell Setup"

# Install Zsh
if ! command_exists zsh; then
    print_tool "Zsh"
    print_step "Installing Zsh package..."
    
    if command_exists apt-get; then
        if run_silent "sudo apt-get update && sudo apt-get install -y zsh"; then
            print_success "Zsh installed"
        else
            print_error "Failed to install Zsh"
            exit 1
        fi
    elif command_exists pacman; then
        if run_silent "sudo pacman -S --noconfirm zsh"; then
            print_success "Zsh installed"
        else
            print_error "Failed to install Zsh"
            exit 1
        fi
    else
        print_error "Unsupported package manager"
        exit 1
    fi
else
    print_tool "Zsh"
    print_success "Already installed"
fi

# Install Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    print_tool "Zinit Plugin Manager"
    print_step "Installing Zinit..."
    
    if run_silent "bash -c \"\$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)\""; then
        print_success "Zinit installed"
    else
        print_error "Failed to install Zinit"
        exit 1
    fi
else
    print_tool "Zinit Plugin Manager"
    print_success "Already installed"
fi

# Change default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    print_tool "Default Shell"
    print_step "Setting Zsh as default shell..."
    
    echo
    print_warning "Administrator password required to change default shell"
    
    if sudo chsh -s "$(which zsh)" "$USER"; then
        print_success "Default shell changed to Zsh"
        print_info "Log out and back in for changes to take effect"
    else
        print_error "Failed to change default shell"
        print_info "You can manually change it later with: chsh -s \$(which zsh)"
    fi
else
    print_tool "Default Shell"
    print_success "Already set to Zsh"
fi

echo