#!/usr/bin/env bash
# lib/config.sh - Configuration and interactive selection

# Ensure mise is available in current session
ensure_mise_active() {
    if command -v mise &> /dev/null; then
        export PATH="$HOME/.local/bin:$PATH"
        eval "$(mise activate bash 2>/dev/null)" || true
    fi
}

# Installation configuration
declare -gA INSTALL_CONFIG=(
    [direnv]=1
    [mise]=1
    [docker]=1
    [k3d]=1
    [zsh]=1
    [cli_tools]=1
    [git_config]=1
    [ssh_keys]=1
    [hosts_config]=1
    [wsl_config]=1
)

# Component metadata (name:description:required)
declare -gA COMPONENT_META=(
    [mise]="Mise:Universal version manager (Python + Node LTS):0"
    [cli_tools]="CLI Tools:FZF, Zoxide, Exa, Bat, Ripgrep:0"
    [zsh]="Zsh + Zinit:Shell with plugins + Starship prompt:0"
    [direnv]="direnv:Environment variable manager:0"
    [docker]="Docker:Docker and container tools:0"
    [k3d]="K3D + Helm:Kubernetes development cluster:0"
    [git_config]="Git Config:Git configuration and aliases:0"
    [ssh_keys]="SSH Keys:Generate SSH keys and add to agent:0"
    [hosts_config]="/etc/hosts:Add custom hosts entries:0"
    [wsl_config]="WSL Config:WSL configuration for K3D and Windows:0"
)

# Get component display order
get_component_order() {
    echo "mise cli_tools zsh direnv docker k3d git_config ssh_keys hosts_config wsl_config"
}

# Check if a component should be installed
should_install() {
    [[ ${INSTALL_CONFIG[$1]} == 1 ]]
}

# Enable a component
enable_install() {
    INSTALL_CONFIG[$1]=1
}

# Disable a component
disable_install() {
    INSTALL_CONFIG[$1]=0
}

# Check if component is required
is_required() {
    local key=$1
    local meta=${COMPONENT_META[$key]}
    local required=$(echo "$meta" | cut -d: -f3)
    [[ $required == 1 ]]
}

# Get component name
get_component_name() {
    local key=$1
    local meta=${COMPONENT_META[$key]}
    echo "$meta" | cut -d: -f1
}

# Get component description
get_component_description() {
    local key=$1
    local meta=${COMPONENT_META[$key]}
    echo "$meta" | cut -d: -f2
}

# Enable all non-required components
enable_all() {
    for key in $(get_component_order); do
        INSTALL_CONFIG[$key]=1
    done
}

# Enable only required components
enable_required_only() {
    for key in $(get_component_order); do
        if is_required "$key"; then
            INSTALL_CONFIG[$key]=1
        else
            INSTALL_CONFIG[$key]=0
        fi
    done
}

# Draw the selection menu
draw_menu() {
    local selected_idx=$1
    local idx=0
    
    # Save cursor position and use tput to redraw without flicker
    # Move to home position (0,0) and clear screen content below
    printf "\033[H\033[J" >&2
    
    echo >&2
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}" >&2
    echo -e "${CYAN}${BOLD}║           Dotfiles Installation - Select Tools            ║${NC}" >&2
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}" >&2
    echo >&2
    echo -e "${DIM}Use ↑/↓ arrows to navigate, Space to toggle, Enter to confirm${NC}" >&2
    echo -e "${DIM}Press 'a' for all, 'r' for required only, 'q' to quit${NC}" >&2
    echo >&2
    
    for key in $(get_component_order); do
        local name=$(get_component_name "$key")
        local desc=$(get_component_description "$key")
        local enabled=${INSTALL_CONFIG[$key]}
        
        # Cursor indicator
        if [ $idx -eq $selected_idx ]; then
            echo -ne "${CYAN}${BOLD}▸${NC} " >&2
        else
            echo -n "  " >&2
        fi
        
        # Checkbox
        if [ $enabled -eq 1 ]; then
            echo -ne "${GREEN}◉${NC} " >&2
        else
            echo -ne "${DIM}○${NC} " >&2
        fi
        
        # Name
        echo -ne "${BOLD}$name${NC}" >&2
        
        # Required tag (check function return code, not output)
        if is_required "$key"; then
            echo -ne " ${RED}[REQUIRED]${NC}" >&2
        fi
        
        echo >&2
        
        # Description (indented)
        if [ $idx -eq $selected_idx ]; then
            echo -e "     ${DIM}$desc${NC}" >&2
        fi
        
        idx=$((idx + 1))
    done
    
    echo >&2
    echo -e "${DIM}─────────────────────────────────────────────────────────${NC}" >&2
    
    # Show summary
    local enabled_count=0
    for key in $(get_component_order); do
        if should_install "$key"; then
            enabled_count=$((enabled_count + 1))
        fi
    done
    
    echo -e "Selected: ${GREEN}$enabled_count${NC} / $(get_component_order | wc -w) components" >&2
}

# Interactive selection menu
prompt_installation_choices() {
    # Always check /dev/tty for terminal availability when piped
    if [ ! -t 0 ] && [ ! -t 1 ]; then
        # Completely non-interactive environment
        if [ ! -c /dev/tty ]; then
            print_info "Non-interactive mode detected, using defaults"
            return 0
        fi
    fi
    
    local selected=0
    local total_items=$(get_component_order | wc -w)
    
    # Clear screen once at the start
    clear
    
    # Hide cursor
    tput civis 2>/dev/null || true
    
    while true; do
        draw_menu $selected
        
        # Read single character from terminal
        read -rsn1 input </dev/tty 2>/dev/null || {
            # If reading fails, fall back to defaults
            tput cnorm 2>/dev/null || true
            print_info "Interactive mode unavailable, using defaults"
            return 0
        }
        
        # Handle escape sequences (arrow keys)
        if [[ $input == $'\x1b' ]]; then
            read -rsn2 input </dev/tty 2>/dev/null
        fi
        
        case $input in
            # Enter key
            "")
                break
                ;;
            # Up arrow
            '[A')
                selected=$((selected - 1))
                if [ $selected -lt 0 ]; then
                    selected=$((total_items - 1))
                fi
                ;;
            # Down arrow
            '[B')
                selected=$((selected + 1))
                if [ $selected -ge $total_items ]; then
                    selected=0
                fi
                ;;
            # Space bar
            ' ')
                local idx=0
                for key in $(get_component_order); do
                    if [ $idx -eq $selected ]; then
                        if ! is_required "$key"; then
                            if should_install "$key"; then
                                disable_install "$key"
                            else
                                enable_install "$key"
                            fi
                        fi
                        break
                    fi
                    idx=$((idx + 1))
                done
                ;;
            # 'a' or 'A' - select all
            [aA])
                enable_all
                ;;
            # 'r' or 'R' - select required only
            [rR])
                enable_required_only
                ;;
            # 'q' or 'Q' - quit
            [qQ])
                tput cnorm 2>/dev/null || true
                echo >&2
                print_error "Installation cancelled by user"
                exit 0
                ;;
        esac
    done
    
    # Show cursor
    tput cnorm 2>/dev/null || true
    
    clear
    echo >&2
    print_success "Installation configuration saved"
    echo >&2
    
    # Show summary
    print_info "☑  Selected components:"
    for key in $(get_component_order); do
        if should_install "$key"; then
            local name=$(get_component_name "$key")
            echo -e "  ${GREEN}✓${NC} $name" >&2
        fi
    done
    echo >&2
}

# Export functions
export -f should_install
export -f enable_install
export -f disable_install