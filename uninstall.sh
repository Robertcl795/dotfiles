#!/bin/bash

# Uninstall Script for Dotfiles
# Removes symlinks and restores backups

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/backup"

print_header "🗑️  Uninstalling Dotfiles"

print_warning "This will remove all dotfiles symlinks and restore backups if available."
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Files to uninstall
FILES=(
    ".zshrc"
    ".gitconfig"
    ".gitconfig.work"
    ".gitconfig.personal"
    ".gitignore_global"
    ".zsh_aliases"
    ".zsh_functions"
)

# Remove symlinks and restore backups
for file in "${FILES[@]}"; do
    filepath="$HOME/$file"
    
    if [[ -L "$filepath" ]]; then
        print_status "Removing symlink: $file"
        rm "$filepath"
        
        # Restore backup if exists
        if [[ -f "$BACKUP_DIR/$file" ]]; then
            print_status "Restoring backup for $file"
            cp "$BACKUP_DIR/$file" "$filepath"
            print_success "Restored $file from backup"
        fi
    elif [[ -f "$filepath" ]]; then
        print_warning "$file exists but is not a symlink, skipping..."
    fi
done

# Remove bin scripts from PATH
if [[ -d "$HOME/.local/bin" ]]; then
    print_status "Removing custom scripts from ~/.local/bin..."
    rm -f "$HOME/.local/bin/ssh-context-manager"
    print_success "Custom scripts removed"
fi

# Ask about SSH config
read -p "Do you want to remove SSH configuration files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Removing SSH config files..."
    rm -f "$HOME/.ssh/config.work"
    rm -f "$HOME/.ssh/config.personal"
    
    # Only remove main config if it was created by our script
    if [[ -f "$HOME/.ssh/config" ]] && grep -q "Include.*config.work" "$HOME/.ssh/config"; then
        read -p "Remove main SSH config? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$HOME/.ssh/config"
            print_success "SSH config files removed"
        fi
    fi
fi

# Ask about .envrc files
read -p "Do you want to remove .envrc files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Removing .envrc files..."
    rm -f "$HOME/work/.envrc"
    rm -f "$HOME/personal/.envrc"
    print_success ".envrc files removed"
fi

print_header "✓ Uninstall Complete"
echo -e "${GREEN}Dotfiles have been uninstalled.${NC}"
echo -e "${YELLOW}Note: The dotfiles repository itself has not been removed.${NC}"
echo -e "${YELLOW}You can delete it manually if desired: rm -rf $DOTFILES_DIR${NC}"
