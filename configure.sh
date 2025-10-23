#!/bin/bash

# Post-Installation Configuration Helper
# Guides users through personalizing their dotfiles setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

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
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${CYAN}➜${NC} $1\n"
}

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    
    read -p "$(echo -e ${BLUE}$prompt ${YELLOW}[$default]${NC}: )" value
    eval $varname="${value:-$default}"
}

print_header "🎨 Dotfiles Post-Installation Configuration"

echo -e "${CYAN}This script will help you personalize your dotfiles setup.${NC}"
echo -e "${YELLOW}Press Enter to accept default values shown in brackets.${NC}\n"

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuration cancelled."
    exit 0
fi

# ============================================================================
# Git Configuration
# ============================================================================

print_header "📝 Git Configuration"

print_step "Work Git Configuration"

prompt_with_default "Work Name" "Your Work Name" work_name
prompt_with_default "Work Email" "you@company.com" work_email

# Update work Git config
cat > "$HOME/.gitconfig.work" << EOF
# ~/.gitconfig.work - Work-specific Git Configuration
# This file is automatically included when working in ~/work directory

[user]
	name = $work_name
	email = $work_email
	# signingkey = YOUR_GPG_KEY_ID

# [commit]
# 	gpgsign = true

[core]
	# Work-specific core settings
	sshCommand = ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work

# Work-specific aliases
[alias]
	# Add any work-specific aliases here
	push-review = push origin HEAD:refs/for/main
EOF

print_success "Work Git config updated"

print_step "Personal Git Configuration"

prompt_with_default "Personal Name" "Your Personal Name" personal_name
prompt_with_default "Personal Email" "your.personal@email.com" personal_email

# Update personal Git config
cat > "$HOME/.gitconfig.personal" << EOF
# ~/.gitconfig.personal - Personal Git Configuration
# This file is automatically included when working in ~/personal directory

[user]
	name = $personal_name
	email = $personal_email
	# signingkey = YOUR_GPG_KEY_ID

# [commit]
# 	gpgsign = true

[core]
	# Personal-specific core settings
	sshCommand = ssh -i ~/.ssh/keys/personal/id_ed25519 -F ~/.ssh/config.personal

# Personal-specific aliases
[alias]
	# Add any personal-specific aliases here
EOF

print_success "Personal Git config updated"

# ============================================================================
# SSH Keys Display
# ============================================================================

print_header "🔑 SSH Keys"

echo -e "${CYAN}Your SSH public keys are ready to be added to GitHub/GitLab/Bitbucket:${NC}\n"

if [[ -f "$HOME/.ssh/keys/work/id_ed25519.pub" ]]; then
    echo -e "${YELLOW}📋 Work SSH Public Key:${NC}"
    echo -e "${GREEN}─────────────────────────────────────────────────────────────${NC}"
    cat "$HOME/.ssh/keys/work/id_ed25519.pub"
    echo -e "${GREEN}─────────────────────────────────────────────────────────────${NC}\n"
fi

if [[ -f "$HOME/.ssh/keys/personal/id_ed25519.pub" ]]; then
    echo -e "${YELLOW}📋 Personal SSH Public Key:${NC}"
    echo -e "${GREEN}─────────────────────────────────────────────────────────────${NC}"
    cat "$HOME/.ssh/keys/personal/id_ed25519.pub"
    echo -e "${GREEN}─────────────────────────────────────────────────────────────${NC}\n"
fi

echo -e "${CYAN}To add these keys to GitHub:${NC}"
echo -e "  1. Go to ${BLUE}https://github.com/settings/keys${NC}"
echo -e "  2. Click 'New SSH key'"
echo -e "  3. Paste the public key above"
echo -e "  4. Give it a descriptive title (e.g., 'Work Laptop' or 'Personal Desktop')\n"

read -p "Press Enter when you've added the SSH keys..."

# ============================================================================
# Test SSH Connections
# ============================================================================

print_header "🧪 Testing SSH Connections"

print_status "Testing work SSH connection to GitHub..."
if ssh -T git@github.com-work 2>&1 | grep -q "successfully authenticated"; then
    print_success "Work SSH connection successful!"
else
    print_warning "Work SSH connection failed. Make sure you've added the key to GitHub."
fi

print_status "Testing personal SSH connection to GitHub..."
if ssh -T git@github.com-personal 2>&1 | grep -q "successfully authenticated"; then
    print_success "Personal SSH connection successful!"
else
    print_warning "Personal SSH connection failed. Make sure you've added the key to GitHub."
fi

# ============================================================================
# Optional Configurations
# ============================================================================

print_header "⚙️  Optional Configurations"

echo -e "${CYAN}Would you like to configure additional settings?${NC}\n"

# Editor preference
print_step "Preferred Editor"
echo "Select your preferred editor:"
echo "  1) vim (default)"
echo "  2) nano"
echo "  3) code (VS Code)"
echo "  4) emacs"
read -p "Choice [1]: " editor_choice

case ${editor_choice:-1} in
    2) editor="nano" ;;
    3) editor="code" ;;
    4) editor="emacs" ;;
    *) editor="vim" ;;
esac

export EDITOR="$editor"
echo "export EDITOR=\"$editor\"" >> "$HOME/.zshrc.local"
print_success "Editor set to $editor"

# GPG Signing
read -p "Do you want to enable GPG commit signing? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "GPG signing setup requires additional configuration."
    echo -e "${YELLOW}See: https://docs.github.com/en/authentication/managing-commit-signature-verification${NC}"
    echo -e "${CYAN}After setting up GPG, uncomment the relevant lines in ~/.gitconfig.work and ~/.gitconfig.personal${NC}"
fi

# ============================================================================
# Context Test
# ============================================================================

print_header "🎯 Testing Context Switching"

print_status "Testing work context..."
cd "$HOME/work"
current_context="${SSH_AUTH_SOCK_CONTEXT:-none}"
if [[ "$current_context" == "work" ]]; then
    print_success "Work context loaded successfully!"
else
    print_warning "Work context not loaded. You may need to run 'direnv allow ~/work'"
fi

print_status "Testing personal context..."
cd "$HOME/personal"
current_context="${SSH_AUTH_SOCK_CONTEXT:-none}"
if [[ "$current_context" == "personal" ]]; then
    print_success "Personal context loaded successfully!"
else
    print_warning "Personal context not loaded. You may need to run 'direnv allow ~/personal'"
fi

cd "$HOME"

# ============================================================================
# Summary
# ============================================================================

print_header "✨ Configuration Complete!"

echo -e "${GREEN}Your dotfiles are now configured!${NC}\n"

echo -e "${CYAN}📝 Summary:${NC}"
echo -e "  • Work Git: ${YELLOW}$work_name <$work_email>${NC}"
echo -e "  • Personal Git: ${YELLOW}$personal_name <$personal_email>${NC}"
echo -e "  • Editor: ${YELLOW}$editor${NC}"
echo -e "  • SSH keys: ${YELLOW}Ready${NC}\n"

echo -e "${CYAN}🚀 Next Steps:${NC}"
echo -e "  1. Open a new terminal or run: ${YELLOW}source ~/.zshrc${NC}"
echo -e "  2. Test context switching: ${YELLOW}cd ~/work && ssh-status${NC}"
echo -e "  3. Clone a repository: ${YELLOW}gclone git@github.com:user/repo.git${NC}"
echo -e "  4. Check out the quickstart guide: ${YELLOW}cat ~/.dotfiles/QUICKSTART.md${NC}\n"

echo -e "${CYAN}📚 Helpful Commands:${NC}"
echo -e "  • ${YELLOW}ssh-status${NC}     - Show current SSH context"
echo -e "  • ${YELLOW}git-whoami${NC}     - Show current Git configuration"
echo -e "  • ${YELLOW}gclone <url>${NC}   - Smart clone with current context"
echo -e "  • ${YELLOW}new-project <name>${NC} - Create new Git project\n"

echo -e "${MAGENTA}Happy coding! 🎉${NC}\n"
