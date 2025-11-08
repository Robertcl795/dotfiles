#!/usr/bin/env bash
# installer/git.sh - Git configuration

print_header "Git Configuration"

# Git should already be installed from bootstrap, but check anyway
if ! command_exists git; then
    print_tool "Git"
    print_step "Installing Git..."
    
    if command_exists apt-get; then
        if run_silent "sudo apt-get update && sudo apt-get install -y git"; then
            print_success "Git installed"
        else
            print_error "Failed to install Git"
            exit 1
        fi
    elif command_exists pacman; then
        if run_silent "sudo pacman -S --noconfirm git"; then
            print_success "Git installed"
        else
            print_error "Failed to install Git"
            exit 1
        fi
    fi
else
    print_tool "Git"
    print_success "Already installed"
fi

# Check if git config exists
if [ ! -f "$HOME/.gitconfig" ]; then
    print_tool "Git Configuration"
    print_step "Setting up git configuration..."
    
    echo
    print_warning "Git user configuration required"
    
    # Get user input
    read -p "Enter your git username: " git_user
    read -p "Enter your git email: " git_email
    
    if [ -n "$git_user" ] && [ -n "$git_email" ]; then
        git config --global user.name "$git_user"
        git config --global user.email "$git_email"
        
        # Set some sensible defaults
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        git config --global core.autocrlf input
        
        print_success "Git configured"
    else
        print_warning "Skipped git configuration (you can configure it later)"
    fi
else
    print_tool "Git Configuration"
    print_success "Already configured"
    
    GIT_USER=$(git config --global user.name)
    GIT_EMAIL=$(git config --global user.email)
    print_info "User: $GIT_USER <$GIT_EMAIL>"
fi

# Install GitHub CLI if not present
if ! command_exists gh; then
    print_tool "GitHub CLI"
    
    if confirm "Install GitHub CLI?" "y"; then
        print_step "Installing GitHub CLI..."
        
        if command_exists apt-get; then
            if run_silent "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
                          sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
                          echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
                          sudo apt-get update && sudo apt-get install -y gh"; then
                print_success "GitHub CLI installed"
            else
                print_warning "Failed to install GitHub CLI"
            fi
        else
            print_warning "GitHub CLI installation not supported on this system"
        fi
    else
        print_info "Skipping GitHub CLI installation"
    fi
else
    print_tool "GitHub CLI"
    print_success "Already installed"
fi

echo