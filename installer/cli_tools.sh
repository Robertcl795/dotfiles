#!/usr/bin/env bash
# installer/cli_tools.sh - Modern CLI tools installation

print_header "Modern CLI Tools"

# Ensure necessary system packages are installed first
print_tool "System Dependencies"
print_step "Installing build tools..."

if command_exists apt-get; then
    run_silent "sudo apt-get update && sudo apt-get install -y build-essential curl wget" && \
        print_success "Build tools installed" || print_warning "Some build tools may already be installed"
fi

# bat - cat with syntax highlighting
if ! command_exists bat && ! command_exists batcat; then
    print_tool "bat (cat replacement)"
    print_step "Installing bat..."
    
    if command_exists apt-get; then
        # Install and verify with either name
        if run_silent "sudo apt-get install -y bat"; then
            # Check both possible names
            if command_exists bat || command_exists batcat; then
                # Create symlink if batcat was installed but bat doesn't exist
                if command_exists batcat && ! command_exists bat; then
                    mkdir -p ~/.local/bin
                    ln -sf "$(which batcat)" ~/.local/bin/bat
                    export PATH="$HOME/.local/bin:$PATH"
                fi
                print_success "bat installed"
            else
                print_error "Failed to verify bat installation"
            fi
        else
            print_error "Failed to install bat"
        fi
    elif command_exists pacman; then
        install_tool "bat" "sudo pacman -S --noconfirm bat"
    else
        print_warning "No package manager found for bat"
    fi
else
    print_tool "bat"
    print_success "Already installed"
fi

# eza (exa replacement) - modern ls replacement
if ! command_exists eza; then
    print_tool "eza (ls replacement)"
    print_step "Installing eza..."
    
    # Try cargo first if available
    if command_exists cargo; then
        install_tool "eza" "cargo install eza"
    else
        # Try downloading prebuilt binary
        print_step "Downloading prebuilt eza binary..."
        if run_silent "wget -qO- https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp && sudo mv /tmp/eza /usr/local/bin/"; then
            if command_exists eza; then
                print_success "eza installed"
            else
                print_warning "eza installation could not be verified"
            fi
        else
            print_warning "Failed to install eza (install Rust/cargo for automatic installation)"
        fi
    fi
else
    print_tool "eza"
    print_success "Already installed"
fi

# fzf - fuzzy finder
if ! command_exists fzf; then
    print_tool "fzf (fuzzy finder)"
    print_step "Installing fzf..."
    
    if [ ! -d ~/.fzf ]; then
        if run_silent "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"; then
            # Install with zsh integration enabled
            if run_silent "~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish"; then
                export PATH="$HOME/.fzf/bin:$PATH"
                print_success "fzf installed"
            else
                print_error "fzf installation failed"
            fi
        else
            print_error "Failed to clone fzf repository"
        fi
    else
        # Directory exists, try to install
        if run_silent "~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish"; then
            export PATH="$HOME/.fzf/bin:$PATH"
            print_success "fzf installed"
        fi
    fi
else
    print_tool "fzf"
    print_success "Already installed"
fi

# zoxide - smart cd
if ! command_exists zoxide; then
    print_tool "zoxide (smart cd)"
    print_step "Installing zoxide..."
    
    # Try cargo first
    if command_exists cargo; then
        install_tool "zoxide" "cargo install zoxide"
    elif command_exists apt-get; then
        # Try package manager
        if ! install_tool "zoxide" "sudo apt-get install -y zoxide"; then
            # Fallback to installation script
            print_step "Trying installation script..."
            if run_silent "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"; then
                export PATH="$HOME/.local/bin:$PATH"
                if command_exists zoxide; then
                    print_success "zoxide installed"
                fi
            fi
        fi
    else
        # Use installation script
        if run_silent "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"; then
            export PATH="$HOME/.local/bin:$PATH"
            if command_exists zoxide; then
                print_success "zoxide installed"
            fi
        fi
    fi
else
    print_tool "zoxide"
    print_success "Already installed"
fi

# ripgrep - fast grep
if ! command_exists rg; then
    print_tool "ripgrep (fast grep)"
    
    if command_exists apt-get; then
        install_tool "ripgrep" "sudo apt-get install -y ripgrep" "rg"
    elif command_exists pacman; then
        install_tool "ripgrep" "sudo pacman -S --noconfirm ripgrep" "rg"
    elif command_exists cargo; then
        install_tool "ripgrep" "cargo install ripgrep" "rg"
    else
        print_warning "No compatible package manager found for ripgrep"
    fi
else
    print_tool "ripgrep"
    print_success "Already installed"
fi

# fd - modern find
if ! command_exists fd && ! command_exists fdfind; then
    print_tool "fd (modern find)"
    print_step "Installing fd..."
    
    if command_exists apt-get; then
        # Install and verify with either name
        if run_silent "sudo apt-get install -y fd-find"; then
            # Check both possible names
            if command_exists fd || command_exists fdfind; then
                # Create symlink if fdfind was installed but fd doesn't exist
                if command_exists fdfind && ! command_exists fd; then
                    mkdir -p ~/.local/bin
                    ln -sf "$(which fdfind)" ~/.local/bin/fd
                    export PATH="$HOME/.local/bin:$PATH"
                fi
                print_success "fd installed"
            else
                print_error "Failed to verify fd installation"
            fi
        else
            print_error "Failed to install fd"
        fi
    elif command_exists pacman; then
        install_tool "fd" "sudo pacman -S --noconfirm fd"
    elif command_exists cargo; then
        install_tool "fd" "cargo install fd-find" "fd"
    else
        print_warning "No compatible package manager found for fd"
    fi
else
    print_tool "fd"
    print_success "Already installed"
fi

echo >&2
