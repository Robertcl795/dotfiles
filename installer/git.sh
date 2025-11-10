#!/usr/bin/env bash
# installer/git.sh - Git configuration

print_header "Git Configuration"

# Git should already be installed from bootstrap, but check anyway
if ! command_exists git; then
    print_tool "Git"
    print_step "Installing Git..."
    
    if command_exists apt-get; then
        if install_tool "git" "sudo apt-get update && sudo apt-get install -y git"; then
            true  # Success
        else
            print_error "Failed to install Git"
            return 1
        fi
    elif command_exists pacman; then
        if ! install_tool "git" "sudo pacman -S --noconfirm git"; then
            print_error "Failed to install Git"
            return 1
        fi
    fi
else
    print_tool "Git"
    print_success "Already installed"
fi

# Check if git config exists
GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$GIT_USER" ] && [ -n "$GIT_EMAIL" ]; then
    print_tool "Git Configuration"
    print_success "Already configured"
    print_info "User: $GIT_USER <$GIT_EMAIL>"
else
    print_tool "Git Configuration"
    print_step "Setting up git configuration..."
    
    echo >&2
    print_warning "Git user configuration required"
    
    # Get user input
    if [ -z "$GIT_USER" ]; then
        read -p "Enter your git username: " git_user </dev/tty
    else
        git_user="$GIT_USER"
    fi
    
    if [ -z "$GIT_EMAIL" ]; then
        read -p "Enter your git email: " git_email </dev/tty
    else
        git_email="$GIT_EMAIL"
    fi
    
    if [ -n "$git_user" ] && [ -n "$git_email" ]; then
        git config --global user.name "$git_user" >> "$DOTFILES_LOG" 2>&1
        git config --global user.email "$git_email" >> "$DOTFILES_LOG" 2>&1
        
        # Set some sensible defaults
        git config --global init.defaultBranch main >> "$DOTFILES_LOG" 2>&1
        git config --global pull.rebase false >> "$DOTFILES_LOG" 2>&1
        git config --global core.autocrlf input >> "$DOTFILES_LOG" 2>&1
        
        print_success "Git configured"
        print_info "User: $git_user <$git_email>"
    else
        print_warning "Skipped git configuration (you can configure it later)"
    fi
fi

# Install GitHub CLI if not present
if ! command_exists gh; then
    print_tool "GitHub CLI"
    
    echo >&2
    if confirm "Install GitHub CLI?" "y"; then
        print_step "Installing GitHub CLI..."
        
        if command_exists apt-get; then
            GHCLI_INSTALL_CMD="curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
                          sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
                          echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
                          sudo apt-get update && sudo apt-get install -y gh"
            
            if install_tool "GitHub CLI" "$GHCLI_INSTALL_CMD" "gh"; then
                true  # Success
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

echo >&2
