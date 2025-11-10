#!/usr/bin/env bash
# installer/ssh_keys.sh - SSH agent setup and key generation helper

print_header "SSH Agent Setup"

print_tool "SSH Agent"

# Ensure GitHub is in known_hosts (should already be done in pre-installation)
if ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
    print_step "Adding GitHub to known_hosts..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null && \
        print_success "GitHub added to known_hosts" || \
        print_warning "Failed to add GitHub to known_hosts"
fi

# Configure SSH agent to start automatically in .zshrc
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "# SSH Agent auto-start" "$HOME/.zshrc"; then
        print_step "Configuring SSH agent auto-start..."
        
        cat >> "$HOME/.zshrc" << 'EOF'

# ============================================================================
# SSH Agent auto-start
# ============================================================================
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null 2>&1
fi

# Helper function to generate SSH keys with ed25519
# Usage: add-ssh your-email@example.com
add-ssh() {
    if [ -z "$1" ]; then
        echo "Usage: add-ssh your-email@example.com"
        return 1
    fi
    
    ssh-keygen -t ed25519 -C "$1" -f ~/.ssh/id_ed25519 && \
    ssh-add ~/.ssh/id_ed25519 && \
    echo "" && \
    echo "✓ SSH key generated and added to agent!" && \
    echo "" && \
    echo "Your public key:" && \
    echo "─────────────────────────────────────────" && \
    cat ~/.ssh/id_ed25519.pub && \
    echo "─────────────────────────────────────────" && \
    echo "" && \
    echo "Add this to:" && \
    echo "  GitHub: https://github.com/settings/keys" && \
    echo "  GitLab: https://gitlab.com/-/profile/keys"
}
EOF
        print_success "SSH agent configured"
        print_info " Added 'add-ssh' function for easy key generation"
    else
        print_success "SSH agent already configured"
    fi
else
    print_warning ".zshrc not found, skipping SSH agent setup"
fi

# Check if SSH key already exists and offer to display it
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
    echo >&2
    print_info "Existing SSH key found"
    
    if confirm "Display public key?" "n"; then
        echo >&2
        print_info "Your public key:"
        echo "─────────────────────────────────────────────────────────" >&2
        cat "${SSH_KEY}.pub" >&2
        echo "─────────────────────────────────────────────────────────" >&2
        echo >&2
    fi
else
    echo >&2
    print_info "No SSH key found"
    print_info "After shell restart, use: ${BOLD}add-ssh your-email@example.com${NC}"
fi

echo >&2
