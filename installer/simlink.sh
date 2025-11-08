#!/usr/bin/env bash
# installer/symlink.sh - Symlink dotfiles to home directory

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Function to create symlink
create_symlink() {
    local source=$1
    local target=$2
    
    # Create parent directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $(basename "$target") to $backup"
        mv "$target" "$backup"
    fi
    
    # Remove existing symlink if it points to wrong location
    if [ -L "$target" ] && [ "$(readlink "$target")" != "$source" ]; then
        rm "$target"
    fi
    
    # Create symlink
    if [ ! -e "$target" ]; then
        ln -sf "$source" "$target"
        print_success "Linked $(basename "$target")"
    else
        print_info "$(basename "$target") already linked"
    fi
}

# Zsh configuration
if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
    print_tool "Zsh Configuration"
    create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]; then
    create_symlink "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
fi

# Starship prompt
if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
    print_tool "Starship Prompt"
    create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# Git configuration
if [ -f "$DOTFILES_DIR/config/git/.gitconfig" ]; then
    print_tool "Git Configuration"
    
    if [ -f "$HOME/.gitconfig" ]; then
        if ! confirm "Overwrite existing .gitconfig?" "n"; then
            print_info "Skipping .gitconfig"
        else
            create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
        fi
    else
        create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    fi
fi

if [ -f "$DOTFILES_DIR/config/git/.gitignore_global" ]; then
    create_symlink "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"
fi

# direnv configuration
if [ -f "$DOTFILES_DIR/config/direnv/direnvrc" ]; then
    print_tool "direnv Configuration"
    create_symlink "$DOTFILES_DIR/config/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
fi

# mise configuration
if [ -f "$DOTFILES_DIR/config/mise/config.toml" ]; then
    print_tool "mise Configuration"
    create_symlink "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"
fi

# bat configuration
if [ -f "$DOTFILES_DIR/config/bat/config" ]; then
    print_tool "bat Configuration"
    create_symlink "$DOTFILES_DIR/config/bat/config" "$HOME/.config/bat/config"
fi

echo