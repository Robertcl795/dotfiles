#!/usr/bin/env bash
# installer/mise.sh - mise-en-place installation

print_header "mise (Version Manager)"

if ! command_exists mise; then
    print_tool "mise"
    print_step "Installing mise..."
    
    if install_tool "mise" "curl -fsSL https://mise.run | sh"; then
        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        
        # Verify it's available
        if ! command_exists mise; then
            print_warning "mise installed but not in PATH, adding manually..."
            export PATH="$HOME/.local/bin:$HOME/.local/share/mise/bin:$PATH"
        fi
    else
        print_error "Failed to install mise"
        return 1
    fi
else
    print_tool "mise"
    print_success "Already installed"
    
    # Ensure mise is in PATH
    export PATH="$HOME/.local/bin:$PATH"
fi

# Activate mise for current session
print_step "Activating mise..."
eval "$(mise activate bash 2>/dev/null)" || {
    print_warning "Failed to activate mise, adding to PATH manually"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
}

# Install Node.js LTS
print_tool "Node.js LTS"
print_step "Installing Node.js via mise..."

if mise use -g node@lts >> "$DOTFILES_LOG" 2>&1; then
    print_success "Node.js LTS installed"
    
    # Refresh mise activation to include new shims
    eval "$(mise activate bash 2>/dev/null)" || true
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    
    # Wait a moment for shims to be created
    sleep 1
    
    # Verify Node is available
    if command_exists node; then
        NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
        print_info "Node.js $NODE_VERSION is now available"
    else
        print_warning "Node.js installed but not yet in PATH (restart shell to use)"
    fi
else
    print_error "Failed to install Node.js"
    cat "$DOTFILES_LOG" | tail -20 >&2
fi

# Install Python 3.12
print_tool "Python 3.12"
print_step "Installing Python via mise..."

if mise use -g python@3.12 >> "$DOTFILES_LOG" 2>&1; then
    print_success "Python 3.12 installed"
    
    # Refresh mise activation
    eval "$(mise activate bash 2>/dev/null)" || true
    
    # Wait for shims
    sleep 1
    
    # Verify Python is available
    if command_exists python || command_exists python3; then
        PYTHON_VERSION=$(python --version 2>/dev/null || python3 --version 2>/dev/null || echo "unknown")
        print_info "$PYTHON_VERSION is now available"
    else
        print_warning "Python installed but not yet in PATH (restart shell to use)"
    fi
else
    print_error "Failed to install Python"
    cat "$DOTFILES_LOG" | tail -20 >&2
fi

# Install pnpm
print_tool "pnpm"

if ! command_exists pnpm; then
    print_step "Installing pnpm via mise..."
    
    if mise use -g pnpm@latest >> "$DOTFILES_LOG" 2>&1; then
        eval "$(mise activate bash 2>/dev/null)" || true
        export PATH="$HOME/.local/share/mise/shims:$PATH"
        sleep 1
        
        if command_exists pnpm; then
            print_success "pnpm installed"
        else
            # Fallback to npm if available
            if command_exists npm; then
                print_step "Falling back to npm installation..."
                if npm install -g pnpm >> "$DOTFILES_LOG" 2>&1; then
                    print_success "pnpm installed via npm"
                else
                    print_warning "Failed to install pnpm"
                fi
            else
                print_warning "pnpm not available in PATH yet (restart shell)"
            fi
        fi
    else
        print_warning "Failed to install pnpm via mise"
        if command_exists npm; then
            print_step "Trying npm installation..."
            if npm install -g pnpm >> "$DOTFILES_LOG" 2>&1; then
                print_success "pnpm installed via npm"
            fi
        fi
    fi
else
    print_success "Already installed"
fi

# Show version info
echo >&2
print_info "Installed versions:"

if command_exists node; then
    NODE_VER=$(node --version 2>/dev/null || echo "not available")
    print_info "  Node.js: $NODE_VER"
else
    print_warning "  Node.js: not in PATH (restart shell)"
fi

if command_exists npm; then
    NPM_VER=$(npm --version 2>/dev/null || echo "not available")
    print_info "  npm: $NPM_VER"
fi

if command_exists pnpm; then
    PNPM_VER=$(pnpm --version 2>/dev/null || echo "not available")
    print_info "  pnpm: $PNPM_VER"
else
    print_warning "  pnpm: not in PATH (restart shell)"
fi

if command_exists python || command_exists python3; then
    PY_VER=$(python --version 2>/dev/null || python3 --version 2>/dev/null || echo "not available")
    print_info "  Python: $PY_VER"
else
    print_warning "  Python: not in PATH (restart shell)"
fi

echo >&2
