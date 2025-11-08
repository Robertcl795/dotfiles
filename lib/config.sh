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
)

# Component metadata (name:description:required)
declare -gA COMPONENT_META=(
    [direnv]="direnv:Environment variable management:0"
    [mise]="mise:Universal version manager (Node, Python, Rust):0"
    [docker]="Docker:Docker and container tools:0"
    [k3d]="K3D + Helm:Kubernetes development cluster:0"
    [zsh]="Zsh + Zinit:Modern shell with plugins:1"
    [cli_tools]="CLI Tools:Modern CLI utilities (bat, eza, fzf, zoxide):0"
    [git_config]="Git Config:Git configuration and aliases:0"
)

# Get component display order
get_component_order() {
    echo "zsh mise cli_tools direnv docker k3d git_config"
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
    
    clear
    echo
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║           Dotfiles Installation - Select Tools            ║${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${DIM}Use ↑/↓ arrows to navigate, Space to toggle, Enter to confirm${NC}"
    echo -e "${DIM}Press 'a' for all, 'r' for required only${NC}"
    echo
    
    for key in $(get_component_order); do
        local name=$(get_component_name "$key")
        local desc=$(get_component_description "$key")
        local enabled=${INSTALL_CONFIG[$key]}
        local required=$(is_required "$key")
        
        # Cursor indicator
        if [ $idx -eq $selected_idx ]; then
            echo -ne "${CYAN}${BOLD}▸${NC} "
        else
            echo -n "  "
        fi
        
        # Checkbox
        if [ $enabled -eq 1 ]; then
            echo -ne "${GREEN}◉${NC} "
        else
            echo -ne "${DIM}○${NC} "
        fi
        
        # Name
        echo -ne "${BOLD}$name${NC}"
        
        # Required tag
        if [ $required -eq 1 ]; then
            echo -ne " ${RED}[REQUIRED]${NC}"
        fi
        
        echo
        
        # Description (indented)
        if [ $idx -eq $selected_idx ]; then
            echo -e "     ${DIM}$desc${NC}"
        fi
        
        idx=$((idx + 1))
    done
    
    echo
    echo -e "${DIM}─────────────────────────────────────────────────────────${NC}"
    
    # Show summary
    local enabled_count=0
    for key in $(get_component_order); do
        if should_install "$key"; then
            enabled_count=$((enabled_count + 1))
        fi
    done
    
    echo -e "Selected: ${GREEN}$enabled_count${NC} / $(get_component_order | wc -w) components"
}

# Interactive selection menu
prompt_installation_choices() {
    if [ ! -t 0 ]; then
        print_info "Non-interactive mode detected, using defaults"
        return 0
    fi
    
    local selected=0
    local total_items=$(get_component_order | wc -w)
    
    # Hide cursor
    tput civis
    
    while true; do
        draw_menu $selected
        
        # Read single character
        read -rsn1 input
        
        # Handle escape sequences (arrow keys)
        if [[ $input == $'\x1b' ]]; then
            read -rsn2 input
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
                tput cnorm
                echo
                print_error "Installation cancelled by user"
                exit 0
                ;;
        esac
    done
    
    # Show cursor
    tput cnorm
    
    clear
    echo
    print_success "Installation configuration saved"
    echo
    
    # Show summary
    print_info "Selected components:"
    for key in $(get_component_order); do
        if should_install "$key"; then
            local name=$(get_component_name "$key")
            echo -e "  ${GREEN}✓${NC} $name"
        fi
    done
    echo
}

# Export functions
export -f should_install
export -f enable_install
export -f disable_install