#!/usr/bin/env bash
# installers/zsh.sh

install_zsh() {
    if ! is_selected "zsh"; then return 0; fi
    print_step "Installing Zsh with Zinit..."

    if ! command_exists zsh; then
        $INSTALL_CMD zsh
    fi

    if [ ! -d "$HOME/.local/share/zinit" ]; then
        bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    fi

    if ! command_exists starship; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    ensure_dir "$HOME/.config"
    safe_link "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    safe_link "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"

    if [ "$SHELL" != "$(which zsh)" ]; then
        if confirm "Change default shell to Zsh?"; then
            chsh -s "$(which zsh)"
        fi
    fi

    print_success "Zsh installed"
}

export -f install_zsh