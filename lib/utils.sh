#!/usr/bin/env bash
# lib/utils.sh - Utility functions

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Log file location
DOTFILES_LOG="${HOME}/.dotfiles-install.log"

# Initialize log file
init_log() {
    mkdir -p "$(dirname "$DOTFILES_LOG")"
    echo "=== Dotfiles Installation Log ===" > "$DOTFILES_LOG"
    echo "Started: $(date)" >> "$DOTFILES_LOG"
    echo "=================================" >> "$DOTFILES_LOG"
    echo >> "$DOTFILES_LOG"
}

# Output functions (always to stderr for visibility)
print_info() { echo -e "${BLUE}ℹ${NC}  $1" >&2; }
print_success() { echo -e "${GREEN}✓${NC}  $1" >&2; }
print_error() { echo -e "${RED}✗${NC}  $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC}  $1" >&2; }

print_header() { 
    echo >&2
    echo -e "${CYAN}${BOLD}━━━ $1 ━━━${NC}" >&2
    echo "=== $1 ===" >> "$DOTFILES_LOG"
}

print_tool() {
    echo -e "${MAGENTA}${BOLD}▸${NC} ${BOLD}$1${NC}" >&2
}

print_step() {
    echo -e "  ${DIM}→${NC} $1" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Execute command and log output, only show errors to console
run_silent() {
    local cmd="$@"
    local output
    local exit_code
    
    # Log command
    echo "$ $cmd" >> "$DOTFILES_LOG"
    
    # Run and capture output
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    
    # Always log output
    echo "$output" >> "$DOTFILES_LOG"
    
    # Show errors on console
    if [ $exit_code -ne 0 ]; then
        echo "$output" >&2
        return $exit_code
    fi
    
    return 0
}

# Install a tool with proper logging and verification
install_tool() {
    local tool_name="$1"
    local install_cmd="$2"
    local verify_cmd="${3:-$tool_name}"
    
    echo >> "$DOTFILES_LOG"
    echo "Installing $tool_name..." >> "$DOTFILES_LOG"
    echo "Command: $install_cmd" >> "$DOTFILES_LOG"
    
    # Run installation
    if run_silent "$install_cmd"; then
        # Verify installation
        if command_exists "$verify_cmd"; then
            print_success "$tool_name installed"
            return 0
        else
            print_error "Failed to verify $tool_name installation"
            echo "Verification failed: $verify_cmd not found in PATH" >> "$DOTFILES_LOG"
            return 1
        fi
    else
        print_error "Failed to install $tool_name"
        return 1
    fi
}

# Backup existing file/directory
backup_if_exists() {
    local target=$1
    if [ -e "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up $target to $backup"
        mv "$target" "$backup"
    fi
}

# Ask for confirmation
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"
    
    # Check if stdin is a terminal
    if [ ! -t 0 ]; then
        # Non-interactive mode, use default
        if [ "$default" = "y" ]; then
            return 0
        else
            return 1
        fi
    fi
    
    if [ "$default" = "y" ]; then
        prompt="$prompt (Y/n)"
        local pattern="^[Nn]$"
    else
        prompt="$prompt (y/N)"
        local pattern="^[Yy]$"
    fi
    
    read -p "$prompt " -n 1 -r </dev/tty
    echo >&2
    
    if [ "$default" = "y" ]; then
        [[ ! $REPLY =~ $pattern ]]
    else
        [[ $REPLY =~ $pattern ]]
    fi
}

# Print a divider
print_divider() {
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}" >&2
}