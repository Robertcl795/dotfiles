#!/usr/bin/env bash
# lib/utils.sh - Common utility functions

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_step() { echo -e "${CYAN}==>${NC} $1"; }

print_header() {
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
}

command_exists() {
    command -v "$1" &> /dev/null
}

is_selected() {
    [[ " ${SELECTED_TOOLS[@]} " =~ " $1 " ]]
}

confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-Y}"
    
    if [[ "$default" == "Y" ]]; then
        read -p "$prompt (Y/n) " -n 1 -r
    else
        read -p "$prompt (y/N) " -n 1 -r
    fi
    echo
    
    if [[ "$default" == "Y" ]]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_info "Created directory: $1"
    fi
}

backup_file() {
    if [ -f "$1" ]; then
        local backup="${1}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$1" "$backup"
        print_info "Backed up $1 to $backup"
    fi
}

safe_link() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
        rm -f "$target"
    fi
    
    ensure_dir "$(dirname "$target")"
    ln -sf "$source" "$target"
    print_success "Linked $source -> $target"
}

export -f print_info print_success print_error print_warning print_step print_header
export -f command_exists is_selected confirm ensure_dir backup_file safe_link