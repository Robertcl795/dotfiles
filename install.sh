#!/usr/bin/env bash
set -euo pipefail

# Allow being called with flags forwarded from bootstrap (e.g. --yes)
ASSUME_YES=false
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y)
      ASSUME_YES=true
      shift
      ;;
    --no-tty)
      export DOTFILES_NO_TTY=1
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
# restore positional if needed
set -- "${POSITIONAL[@]}"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
cd "$DOTFILES_DIR"

# Load utilities first
source lib/utils.sh

# If user asked --yes (non-interactive), override confirm helper to always return success.
# Only do this if the utils.sh defined confirm — overriding is fine for automation.
if [ "${ASSUME_YES}" = true ]; then
  if declare -f confirm >/dev/null 2>&1; then
    confirm() { return 0; }
    print_info "Running in non-interactive mode (--yes): all prompts auto-confirmed."
  fi
fi

# Load configuration
source lib/config.sh

# Welcome banner
clear
echo
echo -e "${CYAN}${BOLD}"
cat << "EOF"
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                     
Modern Development Environment Setup
EOF
echo -e "${NC}"

print_info "WSL Development Environment Installer"
print_divider
echo

# Check if running in WSL
if ! grep -q microsoft /proc/version 2>/dev/null; then
    print_warning "This installer is optimized for WSL"
    echo
    if ! confirm "Continue anyway?" "n"; then
        print_error "Installation cancelled"
        exit 0
    fi
    echo
fi

# Interactive mode check
if [ -t 0 ]; then
    echo
    if confirm "Would you like to customize the installation?" "y"; then
        echo
        prompt_installation_choices
        sleep 1
    else
        echo
        print_info "Using default configuration (all components)"
        echo
        sleep 1
    fi
else
    print_info "Non-interactive mode - using defaults"
    echo
fi

# Installation summary
print_divider
echo
print_info "Starting installation with selected components..."
echo

# Track installation
INSTALL_START=$(date +%s)

# Run installers conditionally
if should_install "zsh"; then
    source installer/zsh.sh
fi

if should_install "mise"; then
    source installer/mise.sh
    
    # Ensure mise is active for subsequent installers
    if command -v mise &> /dev/null; then
        export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
        eval "$(mise activate bash 2>/dev/null)" || true
    fi
fi

if should_install "cli_tools"; then
    source installer/cli_tools.sh
fi

if should_install "direnv"; then
    source installer/direnv.sh
fi

if should_install "docker"; then
    source installer/docker.sh
fi

if should_install "k3d"; then
    source installer/k3d.sh
fi

if should_install "git_config"; then
    source installer/git.sh
fi

# Symlink dotfiles (always run)
print_header "Symlinking Configuration Files"

if [ -f "installer/symlink.sh" ]; then
    source installer/symlink.sh
else
    print_warning "symlink.sh not found, skipping..."
fi

# Calculate installation time
INSTALL_END=$(date +%s)
INSTALL_DURATION=$((INSTALL_END - INSTALL_START))

# Completion message
echo
print_divider
echo
echo -e "${GREEN}${BOLD}✓ Installation Complete!${NC}"
echo
print_info "Installation took ${INSTALL_DURATION} seconds"
echo

# Post-installation instructions
if should_install "zsh"; then
    print_warning "Next steps:"
    echo "  1. Restart your shell or run: ${BOLD}exec zsh${NC}"
    echo "  2. If you changed your default shell, log out and back in"
    echo
fi

if should_install "mise"; then
    print_info "mise is configured. You can install runtimes with:"
    echo "  ${DIM}mise use -g node@lts${NC}"
    echo "  ${DIM}mise use -g python@3.12${NC}"
    echo
fi

if should_install "docker"; then
    print_info "Docker is installed. Start it with:"
    echo "  ${DIM}sudo service docker start${NC}"
    echo
fi

print_success "Your development environment is ready!"
echo