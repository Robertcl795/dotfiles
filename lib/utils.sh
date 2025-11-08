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

# Output functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

print_header() { 
    echo
    echo -e "${CYAN}${BOLD}━━━ $1 ━━━${NC}"
}

print_tool() {
    echo -e "${MAGENTA}${BOLD}▸${NC} ${BOLD}$1${NC}"
}

print_step() {
    echo -e "  ${DIM}→${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Execute command and suppress output unless it fails
run_silent() {
    local output
    local exit_code
    
    output=$(eval "$@" 2>&1)
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "$output" >&2
        return $exit_code
    fi
    
    return 0
}

# Execute command with spinner and suppress output
run_with_spinner() {
    local cmd="$1"
    local message="$2"
    local pid
    local output
    local exit_code
    
    # Start command in background and capture output
    output=$(eval "$cmd" 2>&1) &
    pid=$!
    
    # Spinner characters
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    # Show spinner while command runs
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${DIM}${spin:$i:1}${NC} $message"
        sleep 0.1
    done
    
    # Get exit code
    wait $pid
    exit_code=$?
    
    # Clear spinner line
    printf "\r\033[K"
    
    if [ $exit_code -ne 0 ]; then
        print_error "$message"
        echo "$output" >&2
        return $exit_code
    fi
    
    return 0
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
    
    if [ "$default" = "y" ]; then
        prompt="$prompt (Y/n)"
        local pattern="^[Nn]$"
    else
        prompt="$prompt (y/N)"
        local pattern="^[Yy]$"
    fi
    
    read -p "$prompt " -n 1 -r
    echo
    
    if [ "$default" = "y" ]; then
        [[ ! $REPLY =~ $pattern ]]
    else
        [[ $REPLY =~ $pattern ]]
    fi
}

# Print a divider
print_divider() {
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
}