#!/usr/bin/env bash
# installers/git.sh

setup_git() {
    if ! is_selected "git_setup"; then return 0; fi
    print_step "Setting up Git..."

    echo
    read -p "Git username: " git_user
    read -p "Git email: " git_email
    
    echo
    echo "Pull strategy:"
    echo "  1) merge"
    echo "  2) rebase"
    echo "  3) fast-forward only"
    read -p "Choice (1-3): " choice

    case $choice in
        2) strategy="true" ;;
        3) strategy="false"; git config --global pull.ff only ;;
        *) strategy="false" ;;
    esac

    git config --global user.name "$git_user"
    git config --global user.email "$git_email"
    git config --global pull.rebase "$strategy"
    git config --global init.defaultBranch main
    
    if [ -f "$DOTFILES_DIR/config/git/.gitconfig" ]; then
        grep -v "^\[user\]" "$DOTFILES_DIR/config/git/.gitconfig" >> "$HOME/.gitconfig" 2>/dev/null || true
    fi
    
    if [ -f "$DOTFILES_DIR/config/git/.gitignore_global" ]; then
        safe_link "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"
        git config --global core.excludesfile "$HOME/.gitignore_global"
    fi

    print_success "Git configured"
}

export -f setup_git