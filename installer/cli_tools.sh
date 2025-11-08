#!/usr/bin/env bash
# installer/cli-tools.sh - Modern CLI tools installation

print_header "Modern CLI Tools"

# Helper function to install via cargo if available
install_via_cargo() {
    local package=$1
    local binary=${2:-$package}
    
    if command_exists cargo; then
        print_step "Installing $package via cargo..."
        if run_silent "cargo install $package"; then
            return 0
        fi
    fi
    return 1
}

# bat - cat with syntax highlighting
if ! command_exists bat; then
    print_tool "bat (cat replacement)"
    
    if command_exists apt-get; then
        if run_silent "sudo apt-get install -y bat"; then
            # Create symlink if batcat was installed
            if command_exists batcat && ! command_exists bat; then
                run_silent "mkdir -p ~/.local/bin"
                run_silent "ln -sf \$(which batcat) ~/.local/bin/bat"
            fi
            print_success "bat installed"
        else
            print_warning "Failed to install bat via apt, trying cargo..."
            install_via_cargo "bat" && print_success "bat installed" || print_warning "Failed to install bat"
        fi
    elif command_exists pacman; then
        run_silent "sudo pacman -S --noconfirm bat" && print_success "bat installed" || print_warning "Failed to install bat"
    else
        install_via_cargo "bat" && print_success "bat installed" || print_warning "Failed to install bat"
    fi
else
    print_tool "bat"
    print_success "Already installed"
fi

# eza - modern ls replacement
if ! command_exists eza; then
    print_tool "eza (ls replacement)"
    
    if command_exists cargo; then
        print_step "Installing eza via cargo..."
        if run_silent "cargo install eza"; then
            print_success "eza installed"
        else
            print_warning "Failed to install eza"
        fi
    else
        print_warning "cargo not available, skipping eza (install Rust first)"
    fi
else
    print_tool "eza"
    print_success "Already installed"
fi

# fzf - fuzzy finder
if ! command_exists fzf; then
    print_tool "fzf (fuzzy finder)"
    print_step "Installing fzf..."
    
    if run_silent "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-fish"; then
        print_success "fzf installed"
    else
        print_warning "Failed to install fzf"
    fi
else
    print_tool "fzf"
    print_success "Already installed"
fi

# zoxide - smart cd
if ! command_exists zoxide; then
    print_tool "zoxide (smart cd)"
    
    if command_exists cargo; then
        print_step "Installing zoxide via cargo..."
        if run_silent "cargo install zoxide"; then
            print_success "zoxide installed"
        else
            print_warning "Failed to install zoxide"
        fi
    elif command_exists apt-get; then
        if run_silent "sudo apt-get install -y zoxide"; then
            print_success "zoxide installed"
        else
            print_warning "Failed to install zoxide"
        fi
    else
        print_warning "No compatible package manager found for zoxide"
    fi
else
    print_tool "zoxide"
    print_success "Already installed"
fi

# ripgrep - fast grep
if ! command_exists rg; then
    print_tool "ripgrep (fast grep)"
    
    if command_exists apt-get; then
        run_silent "sudo apt-get install -y ripgrep" && print_success "ripgrep installed" || print_warning "Failed to install ripgrep"
    elif command_exists pacman; then
        run_silent "sudo pacman -S --noconfirm ripgrep" && print_success "ripgrep installed" || print_warning "Failed to install ripgrep"
    elif command_exists cargo; then
        install_via_cargo "ripgrep" "rg" && print_success "ripgrep installed" || print_warning "Failed to install ripgrep"
    else
        print_warning "No compatible package manager found for ripgrep"
    fi
else
    print_tool "ripgrep"
    print_success "Already installed"
fi

# fd - modern find
if ! command_exists fd; then
    print_tool "fd (modern find)"
    
    if command_exists apt-get; then
        run_silent "sudo apt-get install -y fd-find" && print_success "fd installed" || print_warning "Failed to install fd"
        # Create symlink if needed
        if command_exists fdfind && ! command_exists fd; then
            run_silent "mkdir -p ~/.local/bin"
            run_silent "ln -sf \$(which fdfind) ~/.local/bin/fd"
        fi
    elif command_exists pacman; then
        run_silent "sudo pacman -S --noconfirm fd" && print_success "fd installed" || print_warning "Failed to install fd"
    elif command_exists cargo; then
        install_via_cargo "fd-find" "fd" && print_success "fd installed" || print_warning "Failed to install fd"
    else
        print_warning "No compatible package manager found for fd"
    fi
else
    print_tool "fd"
    print_success "Already installed"
fi

echo