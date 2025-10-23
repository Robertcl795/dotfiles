#!/bin/bash

# Enhanced Dotfiles Installation Script
# Creates symlinks and ensures SSH context infrastructure is properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"
BIN_DIR="$DOTFILES_DIR/bin"
HOME_DIR="$HOME"

# Function to print colored output
print_header() {
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  $1"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing files
backup_file() {
    local file="$1"
    local backup_dir="$DOTFILES_DIR/backup"
    
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
        print_warning "Backing up existing $file"
        mkdir -p "$backup_dir"
        cp -r "$file" "$backup_dir/$(basename "$file").backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file if it exists and is not a symlink
    backup_file "$target"
    
    # Remove existing file/symlink
    [[ -e "$target" ]] && rm -rf "$target"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -sf "$source" "$target"
    print_success "Linked $(basename "$source") -> $target"
}

# Function to ensure SSH infrastructure exists
ensure_ssh_infrastructure() {
    print_status "Ensuring SSH infrastructure..."
    
    # Create SSH directories
    mkdir -p "$HOME/.ssh/keys/work"
    mkdir -p "$HOME/.ssh/keys/personal"
    
    # Set proper permissions
    chmod 700 "$HOME/.ssh"
    chmod 700 "$HOME/.ssh/keys"
    chmod 700 "$HOME/.ssh/keys/work"
    chmod 700 "$HOME/.ssh/keys/personal"
    
    # Create main SSH config if it doesn't exist
    if [[ ! -f "$HOME/.ssh/config" ]]; then
        cat > "$HOME/.ssh/config" << 'EOF'
# Main SSH Configuration
# Context-specific configs are included based on directory

# Default settings
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes

# Include context-specific configurations
Include config.work
Include config.personal
EOF
        chmod 600 "$HOME/.ssh/config"
        print_success "Created SSH main config"
    fi
    
    # Create work SSH config if it doesn't exist
    if [[ ! -f "$HOME/.ssh/config.work" ]]; then
        cat > "$HOME/.ssh/config.work" << 'EOF'
# Work SSH Configuration

Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/keys/work/id_ed25519
    IdentitiesOnly yes

Host gitlab.com-work
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/keys/work/id_ed25519
    IdentitiesOnly yes

# Add more work-specific hosts here
EOF
        chmod 600 "$HOME/.ssh/config.work"
        print_success "Created work SSH config"
    fi
    
    # Create personal SSH config if it doesn't exist
    if [[ ! -f "$HOME/.ssh/config.personal" ]]; then
        cat > "$HOME/.ssh/config.personal" << 'EOF'
# Personal SSH Configuration

Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/keys/personal/id_ed25519
    IdentitiesOnly yes

Host gitlab.com-personal
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/keys/personal/id_ed25519
    IdentitiesOnly yes

# Add more personal-specific hosts here
EOF
        chmod 600 "$HOME/.ssh/config.personal"
        print_success "Created personal SSH config"
    fi
    
    print_success "SSH infrastructure ready!"
}

# Function to ensure workspace directories exist
ensure_workspace_directories() {
    print_status "Ensuring workspace directories..."
    
    # Create workspace directories
    mkdir -p "$HOME/work"
    mkdir -p "$HOME/personal"
    
    # Create work .envrc if it doesn't exist
    if [[ ! -f "$HOME/work/.envrc" ]]; then
        cat > "$HOME/work/.envrc" << 'EOF'
# Work environment configuration
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work"
export SSH_AUTH_SOCK_CONTEXT="work"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add work SSH key
if [[ -f ~/.ssh/keys/work/id_ed25519 ]]; then
    ssh-add ~/.ssh/keys/work/id_ed25519 2>/dev/null || true
fi

echo "🏢 Switched to WORK environment"
EOF
        chmod 600 "$HOME/work/.envrc"
        print_success "Created work .envrc"
    fi
    
    # Create personal .envrc if it doesn't exist
    if [[ ! -f "$HOME/personal/.envrc" ]]; then
        cat > "$HOME/personal/.envrc" << 'EOF'
# Personal environment configuration
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/personal/id_ed25519 -F ~/.ssh/config.personal"
export SSH_AUTH_SOCK_CONTEXT="personal"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add personal SSH key
if [[ -f ~/.ssh/keys/personal/id_ed25519 ]]; then
    ssh-add ~/.ssh/keys/personal/id_ed25519 2>/dev/null || true
fi

echo "🏠 Switched to PERSONAL environment"
EOF
        chmod 600 "$HOME/personal/.envrc"
        print_success "Created personal .envrc"
    fi
    
    # Allow direnv for these directories
    if command -v direnv >/dev/null 2>&1; then
        direnv allow "$HOME/work" 2>/dev/null || true
        direnv allow "$HOME/personal" 2>/dev/null || true
        print_success "Allowed direnv for workspaces"
    fi
    
    print_success "Workspace directories ready!"
}

# Function to install dotfiles
install_dotfiles() {
    print_header "Installing Dotfiles"
    
    # Ensure directories exist
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    
    # Link configuration files from config directory
    if [[ -d "$CONFIG_DIR" ]]; then
        for config_file in "$CONFIG_DIR"/.* "$CONFIG_DIR"/*; do
            [[ -f "$config_file" ]] || continue
            
            local filename=$(basename "$config_file")
            [[ "$filename" == "." ]] || [[ "$filename" == ".." ]] && continue
            
            local target="$HOME/$filename"
            create_symlink "$config_file" "$target"
        done
    else
        print_warning "Config directory not found: $CONFIG_DIR"
    fi
    
    print_success "Dotfiles installation completed!"
}

# Function to install bin scripts
install_bin_scripts() {
    print_header "Installing Scripts"
    
    if [[ -d "$BIN_DIR" ]]; then
        for script in "$BIN_DIR"/*; do
            [[ -f "$script" ]] || continue
            
            local filename=$(basename "$script")
            local target="$HOME/.local/bin/$filename"
            
            create_symlink "$script" "$target"
            chmod +x "$script"
        done
        print_success "Scripts installed!"
    else
        print_warning "Bin directory not found: $BIN_DIR"
    fi
}

# Function to setup ZSH
setup_zsh() {
    print_header "Setting up ZSH"
    
    if [[ -f "$DOTFILES_DIR/scripts/setup/setup-zsh.sh" ]]; then
        print_status "Running ZSH setup script..."
        bash "$DOTFILES_DIR/scripts/setup/setup-zsh.sh"
    else
        print_warning "ZSH setup script not found, skipping..."
    fi
}

# Function to setup development tools
setup_dev_tools() {
    print_header "Setting up Development Tools"
    
    if [[ -f "$DOTFILES_DIR/scripts/setup/install-dev-tools.sh" ]]; then
        print_status "Running dev tools installation..."
        bash "$DOTFILES_DIR/scripts/setup/install-dev-tools.sh"
    else
        print_warning "Dev tools installation script not found, skipping..."
    fi
}

# Function to create helper scripts if they don't exist
create_helper_scripts() {
    print_header "Creating Helper Scripts"
    
    # Create test-ssh-context if it doesn't exist
    if [[ ! -f "$HOME/.local/bin/test-ssh-context" ]]; then
        cat > "$HOME/.local/bin/test-ssh-context" << 'EOF'
#!/bin/bash

echo "🔍 Testing SSH Context"
echo "======================"
echo ""
echo "Current directory: $(pwd)"
echo "SSH_AUTH_SOCK_CONTEXT: ${SSH_AUTH_SOCK_CONTEXT:-not set}"
echo "GIT_SSH_COMMAND: ${GIT_SSH_COMMAND:-not set}"
echo ""
echo "Loaded SSH keys:"
ssh-add -l 2>/dev/null || echo "No SSH keys loaded"
echo ""
echo "Git user configuration:"
echo "  Name:  $(git config user.name)"
echo "  Email: $(git config user.email)"
EOF
        chmod +x "$HOME/.local/bin/test-ssh-context"
        print_success "Created test-ssh-context script"
    fi
    
    # Ensure ssh-context-manager is executable
    if [[ -f "$HOME/.local/bin/ssh-context-manager" ]]; then
        chmod +x "$HOME/.local/bin/ssh-context-manager"
    fi
}

# Function to add direnv hook to shell rc files if not present
add_direnv_hook() {
    print_status "Ensuring direnv hook is configured..."
    
    local rc_files=("$HOME/.zshrc" "$HOME/.bashrc")
    
    for rc_file in "${rc_files[@]}"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "direnv hook" "$rc_file"; then
                echo '' >> "$rc_file"
                echo '# direnv hook' >> "$rc_file"
                
                if [[ "$rc_file" == *".zshrc" ]]; then
                    echo 'eval "$(direnv hook zsh)"' >> "$rc_file"
                else
                    echo 'eval "$(direnv hook bash)"' >> "$rc_file"
                fi
                
                print_success "Added direnv hook to $rc_file"
            fi
        fi
    done
}

# Function to display post-installation instructions
show_post_install_instructions() {
    print_header "Installation Complete!"
    
    cat << EOF

${GREEN}╔════════════════════════════════════════════════════════════╗
║  Dotfiles Successfully Installed! 🎉                       ║
╚════════════════════════════════════════════════════════════╝${NC}

${CYAN}📁 Configuration Files:${NC}
   • ZSH config: ${YELLOW}~/.zshrc${NC}
   • Git config: ${YELLOW}~/.gitconfig${NC}
   • SSH config: ${YELLOW}~/.ssh/config${NC}

${CYAN}🔐 SSH Context Directories:${NC}
   • Work: ${YELLOW}~/work${NC}
   • Personal: ${YELLOW}~/personal${NC}

${CYAN}🎯 Next Steps:${NC}
   1. ${GREEN}Restart your shell:${NC}
      ${YELLOW}exec zsh${NC}
   
   2. ${GREEN}Configure Git credentials:${NC}
      ${YELLOW}nano ~/.gitconfig.work${NC}
      ${YELLOW}nano ~/.gitconfig.personal${NC}
   
   3. ${GREEN}Generate SSH keys (if not done):${NC}
      ${YELLOW}ssh-context-manager add-key work${NC}
      ${YELLOW}ssh-context-manager add-key personal${NC}
   
   4. ${GREEN}Test your setup:${NC}
      ${YELLOW}cd ~/work && ssh-status${NC}
      ${YELLOW}cd ~/personal && ssh-status${NC}

${CYAN}📚 Useful Commands:${NC}
   • ${YELLOW}ssh-status${NC} - Check current SSH context
   • ${YELLOW}ssh-test${NC} - Test SSH connections
   • ${YELLOW}envinfo${NC} - Show environment information
   • ${YELLOW}sshc help${NC} - SSH context manager help

${CYAN}🐛 Troubleshooting:${NC}
   • If direnv doesn't work: ${YELLOW}direnv allow ~/work${NC}
   • Check setup: ${YELLOW}test-ssh-context${NC}
   • View configs: ${YELLOW}sshc config${NC}

${YELLOW}⚠️  Remember to restart your shell for changes to take effect!${NC}

EOF
}

# Main installation function
main() {
    print_header "Starting Dotfiles Installation"
    print_status "Dotfiles directory: $DOTFILES_DIR"
    
    # Check if we're in the right directory
    if [[ ! -f "$DOTFILES_DIR/install.sh" ]]; then
        print_error "This script should be run from the dotfiles directory"
        exit 1
    fi
    
    # Run installations
    ensure_ssh_infrastructure
    ensure_workspace_directories
    install_dotfiles
    install_bin_scripts
    create_helper_scripts
    add_direnv_hook
    
    # Optional: Setup ZSH and dev tools (comment out if already done)
    # setup_zsh
    # setup_dev_tools
    
    show_post_install_instructions
}

# Run main function
main "$@"