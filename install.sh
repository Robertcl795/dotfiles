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

# Initialize logging
init_log

print_info "Installation log: $DOTFILES_LOG"

# If user asked --yes (non-interactive), override confirm helper to always return success.
if [ "${ASSUME_YES}" = true ]; then
  if declare -f confirm >/dev/null 2>&1; then
    confirm() { return 0; }
    print_info "Running in non-interactive mode (--yes): all prompts auto-confirmed"
  fi
fi

# Load configuration
source lib/config.sh

# Welcome banner
clear
echo >&2
echo -e "${CYAN}${BOLD}" >&2
cat << "EOF" >&2
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                     
Modern Development Environment Setup
EOF
echo -e "${NC}" >&2

print_info "WSL Development Environment Installer"
print_divider
echo >&2

# Check if running in WSL
if ! grep -q microsoft /proc/version 2>/dev/null; then
    print_warning "This installer is optimized for WSL"
    echo >&2
    if ! confirm "Continue anyway?" "n"; then
        print_error "Installation cancelled"
        exit 0
    fi
    echo >&2
fi

# Interactive mode check - check for /dev/tty availability
if [ -c /dev/tty ]; then
    echo >&2
    if confirm "Would you like to customize the installation?" "y"; then
        echo >&2
        prompt_installation_choices
        sleep 1
    else
        echo >&2
        print_info "Using default configuration (all components)"
        echo >&2
        sleep 1
    fi
else
    print_info "Non-interactive mode - using defaults"
    echo >&2
fi

# Installation summary
print_divider
echo >&2
print_info "Starting installation with selected components..."
echo >&2

# Track installation
INSTALL_START=$(date +%s)

# ============================================================================
# Pre-installation: Setup GitHub SSH (required for Zinit plugins)
# ============================================================================
print_header "Pre-installation Setup"

print_step "Adding GitHub to known_hosts for SSH access..."

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
    if ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null; then
        print_success "GitHub added to known_hosts"
    else
        print_warning "Failed to add GitHub to known_hosts (will retry later)"
    fi
else
    print_success "GitHub already in known_hosts"
fi

echo >&2

# ============================================================================
# Component Installation
# ============================================================================

# Run installers conditionally based on order
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
    
    # Update PATH with newly installed tools
    export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"
fi

if should_install "direnv"; then
    source installer/direnv.sh
fi

if should_install "docker"; then
    source installer/docker.sh
fi

if should_install "k3d"; then
    # Check if docker is available first
    if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
        source installer/k3d.sh
    else
        print_warning "Docker not available, skipping K3D installation"
        echo >&2
    fi
fi

if should_install "git_config"; then
    source installer/git.sh
fi

# Symlink dotfiles (always run)
print_header "Symlinking Configuration Files"

if [ -f "installer/symlink.sh" ] || [ -f "installer/simlink.sh" ]; then
    # Handle both spellings
    if [ -f "installer/symlink.sh" ]; then
        source installer/symlink.sh
    else
        source installer/simlink.sh
    fi
else
    print_warning "symlink script not found, skipping..."
fi

# SSH keys should be generated after git is configured
if should_install "ssh_keys"; then
    source installer/ssh_keys.sh
fi

# Hosts config at the end
if should_install "hosts_config"; then
    source installer/hosts_config.sh
fi

# WSL configuration (should be last as it requires restart)
if should_install "wsl_config"; then
    source installer/wsl_config.sh
fi

# Calculate installation time
INSTALL_END=$(date +%s)
INSTALL_DURATION=$((INSTALL_END - INSTALL_START))

# Completion message
echo >&2
print_divider
echo >&2
echo -e "${GREEN}${BOLD}✓ Installation Complete!${NC}" >&2
echo >&2
print_info "Installation took ${INSTALL_DURATION} seconds"
print_info "Detailed log saved to: $DOTFILES_LOG"
echo >&2

# Post-installation instructions
print_warning "Next steps:"
echo -e "  1. Restart your shell or run: ${BOLD}exec zsh${NC}" >&2
echo "  2. If you changed your default shell, log out and back in" >&2

if should_install "mise"; then
    echo -e "  3. Verify mise tools: ${DIM}mise list${NC}" >&2
fi

if should_install "ssh_keys" && [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo "  4. Add your SSH key to GitHub/GitLab if not done already" >&2
fi

echo >&2

print_success "Your development environment is ready!"
echo >&2
