#!/bin/bash

# Bootstrap Script - Fresh WSL/Linux to Power User Dev Environment
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# Configuration
DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
WORK_DIR="$HOME/work"
PERSONAL_DIR="$HOME/personal"

print_header "🚀 Starting Bootstrap Process"

# Step 1: Install essential packages
print_status "Installing essential packages..."
sudo apt update
sudo apt install -y \
    git \
    curl \
    wget \
    zsh \
    build-essential \
    unzip \
    direnv \
    keychain

print_success "Essential packages installed!"

# Step 2: Clone dotfiles repository
print_header "📦 Setting up Dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    print_warning "Dotfiles directory already exists. Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull
else
    print_status "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
print_success "Dotfiles repository ready!"

# Step 3: Setup SSH infrastructure
print_header "🔐 Setting up SSH Infrastructure"

mkdir -p "$HOME/.ssh/keys/work"
mkdir -p "$HOME/.ssh/keys/personal"
chmod 700 "$HOME/.ssh"
chmod 700 "$HOME/.ssh/keys"
chmod 700 "$HOME/.ssh/keys/work"
chmod 700 "$HOME/.ssh/keys/personal"

print_success "SSH directory structure created!"

# Step 4: Create workspace directories
print_header "📁 Creating Workspace Directories"

mkdir -p "$WORK_DIR"
mkdir -p "$PERSONAL_DIR"

# Create .envrc files for direnv
cat > "$WORK_DIR/.envrc" << 'EOF'
# Work environment configuration
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work"
export SSH_AUTH_SOCK_CONTEXT="work"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add work SSH key
ssh-add ~/.ssh/keys/work/id_ed25519 2>/dev/null || true

echo "🏢 Switched to WORK environment"
EOF

cat > "$PERSONAL_DIR/.envrc" << 'EOF'
# Personal environment configuration
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/personal/id_ed25519 -F ~/.ssh/config.personal"
export SSH_AUTH_SOCK_CONTEXT="personal"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add personal SSH key
ssh-add ~/.ssh/keys/personal/id_ed25519 2>/dev/null || true

echo "🏠 Switched to PERSONAL environment"
EOF

chmod 600 "$WORK_DIR/.envrc"
chmod 600 "$PERSONAL_DIR/.envrc"

# Allow direnv for these directories
direnv allow "$WORK_DIR"
direnv allow "$PERSONAL_DIR"

print_success "Workspace directories configured with direnv!"

# Step 5: Run main installation script
print_header "🔧 Running Main Installation"

if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
    chmod +x "$DOTFILES_DIR/install.sh"
    "$DOTFILES_DIR/install.sh"
else
    print_warning "install.sh not found, skipping..."
fi

# Step 6: Setup SSH keys prompt
print_header "🔑 SSH Key Setup"

setup_ssh_keys() {
    local context=$1
    local key_path="$HOME/.ssh/keys/$context/id_ed25519"
    
    echo -e "\n${CYAN}Setting up SSH keys for: ${YELLOW}$context${NC}"
    
    if [[ -f "$key_path" ]]; then
        print_warning "SSH key already exists for $context"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    read -p "Enter email for $context SSH key: " email
    
    if [[ -z "$email" ]]; then
        print_warning "Skipping SSH key generation for $context (no email provided)"
        return
    fi
    
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
    chmod 600 "$key_path"
    chmod 644 "$key_path.pub"
    
    print_success "SSH key generated for $context!"
    echo -e "\n${GREEN}Public key:${NC}"
    cat "$key_path.pub"
    echo -e "\n${YELLOW}Add this key to your Git hosting service (GitHub/GitLab/etc.)${NC}"
    echo -e "${YELLOW}Press Enter when done...${NC}"
    read
}

# Prompt for SSH key setup
echo -e "\n${CYAN}Would you like to generate SSH keys now?${NC}"
read -p "Generate work SSH key? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    setup_ssh_keys "work"
fi

read -p "Generate personal SSH key? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    setup_ssh_keys "personal"
fi

# Step 7: Create SSH config files
print_header "⚙️  Configuring SSH"

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

# Work SSH config
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

# Personal SSH config
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

chmod 600 "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config.work"
chmod 600 "$HOME/.ssh/config.personal"

print_success "SSH configuration files created!"

# Step 8: Setup Git configurations
print_header "🔀 Setting up Git Configurations"

# Create conditional Git config
cat > "$HOME/.gitconfig" << 'EOF'
[user]
    # Default user (fallback)
    name = Your Name
    email = default@example.com

# Include work config when in work directory
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work

# Include personal config when in personal directory
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig.personal

[core]
    editor = code --wait
    autocrlf = input
    pager = delta

[init]
    defaultBranch = main

[push]
    default = current
    autoSetupRemote = true

[pull]
    rebase = true

[delta]
    navigate = true
    light = false
    side-by-side = true

[interactive]
    diffFilter = delta --color-only

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
EOF

# Work Git config
cat > "$HOME/.gitconfig.work" << 'EOF'
[user]
    name = Your Work Name
    email = work@company.com
    
[core]
    sshCommand = ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work
EOF

# Personal Git config
cat > "$HOME/.gitconfig.personal" << 'EOF'
[user]
    name = Your Personal Name
    email = personal@email.com
    
[core]
    sshCommand = ssh -i ~/.ssh/keys/personal/id_ed25519 -F ~/.ssh/config.personal
EOF

print_success "Git configurations created!"

# Step 9: Final touches
print_header "🎨 Final Configuration"

# Add direnv hook to shell rc files
add_direnv_hook() {
    local rc_file=$1
    
    if [[ -f "$rc_file" ]] && ! grep -q "direnv hook" "$rc_file"; then
        echo -e "\n# direnv hook" >> "$rc_file"
        echo 'eval "$(direnv hook zsh)"' >> "$rc_file"
        print_success "Added direnv hook to $rc_file"
    fi
}

add_direnv_hook "$HOME/.zshrc"

# Create helper script for testing SSH setup
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
ssh-add -l
echo ""
echo "Git user configuration:"
git config user.name
git config user.email
EOF

chmod +x "$HOME/.local/bin/test-ssh-context"

print_success "Helper scripts created!"

# Step 10: Summary
print_header "✅ Bootstrap Complete!"

cat << EOF

${GREEN}╔════════════════════════════════════════════════════════════╗
║  Your development environment is ready! 🎉                 ║
╚════════════════════════════════════════════════════════════╝${NC}

${CYAN}📁 Workspace Structure:${NC}
   • Work projects: ${YELLOW}$WORK_DIR${NC}
   • Personal projects: ${YELLOW}$PERSONAL_DIR${NC}

${CYAN}🔐 SSH Keys Location:${NC}
   • Work: ${YELLOW}~/.ssh/keys/work/id_ed25519${NC}
   • Personal: ${YELLOW}~/.ssh/keys/personal/id_ed25519${NC}

${CYAN}🎯 Next Steps:${NC}
   1. ${GREEN}Edit Git configs:${NC}
      • ${YELLOW}~/.gitconfig.work${NC} - Add your work name/email
      • ${YELLOW}~/.gitconfig.personal${NC} - Add your personal name/email
   
   2. ${GREEN}Restart your shell:${NC}
      ${YELLOW}exec zsh${NC}
   
   3. ${GREEN}Test SSH context switching:${NC}
      ${YELLOW}cd ~/work && test-ssh-context${NC}
      ${YELLOW}cd ~/personal && test-ssh-context${NC}
   
   4. ${GREEN}Clone repositories:${NC}
      • For work: ${YELLOW}cd ~/work && git clone git@github.com-work:company/repo.git${NC}
      • For personal: ${YELLOW}cd ~/personal && git clone git@github.com-personal:username/repo.git${NC}

${CYAN}🔧 Useful Commands:${NC}
   • ${YELLOW}test-ssh-context${NC} - Check current SSH context
   • ${YELLOW}ssh-add -l${NC} - List loaded SSH keys
   • ${YELLOW}direnv allow .${NC} - Allow direnv in current directory

${CYAN}📖 Documentation:${NC}
   • Direnv: https://direnv.net/
   • SSH Config: man ssh_config
   • Git Conditional Includes: git help config

EOF

print_warning "Remember to restart your shell: exec zsh"