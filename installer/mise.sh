#!/usr/bin/env bash
# installer/mise.sh - mise-en-place installation

print_header "mise (Version Manager)"

if ! command_exists mise; then
    print_tool "mise"
    print_step "Installing mise..."
    
    if run_silent "curl https://mise.run | sh"; then
        print_success "mise installed"
        
        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
    else
        print_error "Failed to install mise"
        exit 1
    fi
else
    print_tool "mise"
    print_success "Already installed"
    
    # Ensure mise is in PATH
    export PATH="$HOME/.local/bin:$PATH"
fi

# Activate mise for current session
eval "$(mise activate bash 2>/dev/null)" || true

# Install default runtimes
print_tool "Node.js LTS"
print_step "Installing Node.js via mise..."

# Use mise without run_silent to capture but not show output unless error
if OUTPUT=$(mise use -g node@lts 2>&1); then
    print_success "Node.js LTS installed"
    
    # Ensure mise shims are activated
    eval "$(mise activate bash 2>/dev/null)" || true
    
    # Refresh path to include mise shims
    export PATH="$HOME/.local/share/mise/installs/node/lts/bin:$HOME/.local/share/mise/shims:$PATH"
    
    # Verify Node is available
    if command_exists node; then
        NODE_VERSION=$(node --version 2>/dev/null)
        print_info "Node.js $NODE_VERSION is now available"
    fi
else
    print_warning "Failed to install Node.js"
    echo "$OUTPUT" >&2
fi

print_tool "Python 3.12"
print_step "Installing Python via mise..."

if OUTPUT=$(mise use -g python@3.12 2>&1); then
    print_success "Python 3.12 installed"
    
    # Verify Python is available
    if command_exists python; then
        PYTHON_VERSION=$(python --version 2>/dev/null)
        print_info "$PYTHON_VERSION is now available"
    fi
else
    print_warning "Failed to install Python"
fi

# Install pnpm - use mise first, then npm as fallback
print_tool "pnpm"

if ! command_exists pnpm; then
    print_step "Installing pnpm via mise..."
    
    if OUTPUT=$(mise use -g pnpm@latest 2>&1); then
        print_success "pnpm installed via mise"
        eval "$(mise activate bash 2>/dev/null)" || true
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    else
        # Fallback to npm if available
        if command_exists npm; then
            print_step "Falling back to npm installation..."
            if OUTPUT=$(npm install -g pnpm 2>&1); then
                print_success "pnpm installed via npm"
            else
                print_warning "Failed to install pnpm"
                print_info "You can install it later with: npm install -g pnpm"
            fi
        else
            print_warning "npm not available yet"
            print_info "After shell reload, install pnpm with: mise use -g pnpm@latest"
        fi
    fi
else
    print_success "Already installed"
fi

# Show version info
echo
if command_exists node; then
    print_info "✓ Node.js $(node --version 2>/dev/null)"
fi

if command_exists npm; then
    print_info "✓ npm $(npm --version 2>/dev/null)"
fi

if command_exists pnpm; then
    print_info "✓ pnpm $(pnpm --version 2>/dev/null)"
fi

echo