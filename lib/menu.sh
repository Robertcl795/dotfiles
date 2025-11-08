#!/usr/bin/env bash
# lib/menu.sh - Interactive tool selection

declare -gA TOOLS
TOOLS["direnv"]="Environment variable manager"
TOOLS["mise"]="Universal version manager (Node, Python, Rust)"
TOOLS["docker"]="Docker tools (assumes Docker Desktop)"
TOOLS["k3d"]="K3D for local Kubernetes"
TOOLS["helm"]="Helm package manager"
TOOLS["zsh"]="Zsh shell with Zinit"
TOOLS["modern_cli"]="Modern CLI tools (bat, eza, etc)"
TOOLS["git_setup"]="Git configuration"

select_tools() {
    print_header "Tool Selection"
    print_info "Select tools to install (all selected by default)"
    echo
    
    export SELECTED_TOOLS=(direnv mise docker k3d helm zsh modern_cli git_setup)
    
    if command_exists dialog; then
        use_dialog_menu
    else
        use_simple_menu
    fi
    
    echo
    print_success "Selected: ${SELECTED_TOOLS[*]}"
    echo
    
    if ! confirm "Continue with installation?"; then
        print_info "Cancelled"
        exit 0
    fi
}

use_dialog_menu() {
    local opts=()
    for tool in direnv mise docker k3d helm zsh modern_cli git_setup; do
        opts+=("$tool" "${TOOLS[$tool]}" "ON")
    done

    local result
    result=$(dialog --stdout --checklist "Select tools:" 20 70 10 "${opts[@]}")
    
    if [ $? -eq 0 ]; then
        SELECTED_TOOLS=($result)
    else
        print_error "Cancelled"
        exit 1
    fi
    clear
}

use_simple_menu() {
    echo "Available tools:"
    local i=1
    for tool in direnv mise docker k3d helm zsh modern_cli git_setup; do
        echo "  [$i] [X] $tool - ${TOOLS[$tool]}"
        ((i++))
    done
    echo
    echo "Enter numbers to toggle or press Enter to install all:"
    read -r toggle_input

    if [ -n "$toggle_input" ]; then
        local tool_array=(direnv mise docker k3d helm zsh modern_cli git_setup)
        local new_selection=()
        
        for tool in "${tool_array[@]}"; do
            local excluded=false
            for num in $toggle_input; do
                if [ "$num" -ge 1 ] && [ "$num" -le 8 ]; then
                    if [ "${tool_array[$((num-1))]}" == "$tool" ]; then
                        excluded=true
                        break
                    fi
                fi
            done
            [ "$excluded" == "false" ] && new_selection+=("$tool")
        done
        
        SELECTED_TOOLS=("${new_selection[@]}")
    fi
}

export -f select_tools use_dialog_menu use_simple_menu