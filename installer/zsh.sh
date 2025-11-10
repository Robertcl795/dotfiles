#!/usr/bin/env bash
# installer/zsh.sh - Zsh and Zinit installation

print_header "Zsh Shell Setup"

# Install Zsh
if ! command_exists zsh; then
    print_tool "Zsh"
    print_step "Installing Zsh package..."
    
    if command_exists apt-get; then
        # Install without using install_tool since zsh location varies
        if run_silent "sudo apt-get update && sudo apt-get install -y zsh"; then
            # Verify installation by checking common locations
            if command -v zsh >/dev/null 2>&1 || [ -f /usr/bin/zsh ] || [ -f /bin/zsh ]; then
                print_success "Zsh installed"
            else
                print_error "Failed to verify Zsh installation"
                return 1
            fi
        else
            print_error "Failed to install Zsh"
            return 1
        fi
    elif command_exists pacman; then
        if install_tool "Zsh" "sudo pacman -S --noconfirm zsh" "zsh"; then
            true  # Success
        else
            print_error "Failed to install Zsh"
            return 1
        fi
    else
        print_error "Unsupported package manager"
        return 1
    fi
else
    print_tool "Zsh"
    print_success "Already installed"
fi

# Install Zinit - Defer to .zshrc on first load
# This ensures SSH keys and git configs are set up before Zinit clones plugins
print_tool "Zinit Plugin Manager"
print_info "Will be installed automatically on first Zsh launch"

# Install Starship prompt
if ! command_exists starship; then
    print_tool "Starship Prompt"
    print_step "Installing Starship..."
    
    if run_silent "curl -sS https://starship.rs/install.sh | sh -s -- -y"; then
        # Ensure starship is in PATH
        export PATH="$HOME/.local/bin:$PATH"
        
        if command_exists starship; then
            print_success "Starship installed"
            STARSHIP_VERSION=$(starship --version 2>/dev/null | head -n1 || echo "unknown")
            print_info " $STARSHIP_VERSION"
        else
            print_warning "Starship installed but not in PATH yet"
        fi
    else
        print_error "Failed to install Starship"
        print_info "You can install it later with: curl -sS https://starship.rs/install.sh | sh"
    fi
else
    print_tool "Starship Prompt"
    print_success "Already installed"
fi

# Change default shell - use full path to zsh
ZSH_PATH=$(command -v zsh 2>/dev/null || echo "/usr/bin/zsh")

if [ "$SHELL" != "$ZSH_PATH" ]; then
    print_tool "Default Shell"
    print_step "Setting Zsh as default shell..."
    
    echo >&2
    print_warning "Administrator password required to change default shell"
    
    if sudo chsh -s "$ZSH_PATH" "$USER" 2>> "$DOTFILES_LOG"; then
        print_success "Default shell changed to Zsh"
        print_info " Log out and back in for changes to take effect"
    else
        print_error "Failed to change default shell"
        print_info "You can manually change it later with: chsh -s \$(which zsh)"
    fi
else
    print_tool "Default Shell"
    print_success "Already set to Zsh"
fi

echo >&2
