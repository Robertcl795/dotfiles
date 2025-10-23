#!/bin/bash

# SSH Context Manager
# Advanced helper for managing multiple SSH identities

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to display help
show_help() {
    cat << EOF
${CYAN}SSH Context Manager${NC}

${YELLOW}Usage:${NC}
    ssh-context-manager [command] [options]

${YELLOW}Commands:${NC}
    ${GREEN}status${NC}              Show current SSH context and loaded keys
    ${GREEN}test${NC}                Test SSH connections for current context
    ${GREEN}switch${NC} <context>    Switch to a specific SSH context (work/personal)
    ${GREEN}list${NC}                List all available SSH contexts
    ${GREEN}add-key${NC} <context>   Add a new SSH key to specified context
    ${GREEN}clone${NC} <url>         Smart clone using current context
    ${GREEN}config${NC}              Show current SSH and Git configuration
    ${GREEN}help${NC}                Show this help message

${YELLOW}Examples:${NC}
    ${BLUE}ssh-context-manager status${NC}
    ${BLUE}ssh-context-manager test${NC}
    ${BLUE}ssh-context-manager clone git@github.com:user/repo.git${NC}
    ${BLUE}ssh-context-manager switch work${NC}

${YELLOW}Environment Variables:${NC}
    ${CYAN}SSH_AUTH_SOCK_CONTEXT${NC}    Current SSH context (work/personal)
    ${CYAN}GIT_SSH_COMMAND${NC}           Current Git SSH command

EOF
}

# Function to detect current context
detect_context() {
    local current_dir=$(pwd)
    
    if [[ "$current_dir" == "$HOME/work"* ]]; then
        echo "work"
    elif [[ "$current_dir" == "$HOME/personal"* ]]; then
        echo "personal"
    else
        echo "none"
    fi
}

# Function to show status
show_status() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  SSH Context Status                                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    local context=$(detect_context)
    local env_context=${SSH_AUTH_SOCK_CONTEXT:-"not set"}
    
    echo -e "${YELLOW}Current Directory:${NC} $(pwd)"
    echo -e "${YELLOW}Detected Context:${NC} $context"
    echo -e "${YELLOW}Environment Context:${NC} $env_context"
    echo ""
    
    echo -e "${YELLOW}Git Configuration:${NC}"
    echo -e "  Name:  $(git config user.name)"
    echo -e "  Email: $(git config user.email)"
    echo ""
    
    echo -e "${YELLOW}SSH Keys Loaded:${NC}"
    if ssh-add -l &>/dev/null; then
        ssh-add -l | while read -r line; do
            echo -e "  ${GREEN}✓${NC} $line"
        done
    else
        echo -e "  ${RED}✗${NC} No SSH keys loaded"
    fi
    echo ""
    
    echo -e "${YELLOW}GIT_SSH_COMMAND:${NC}"
    echo -e "  ${GIT_SSH_COMMAND:-not set}"
}

# Function to test SSH connections
test_connections() {
    local context=$(detect_context)
    
    echo -e "${CYAN}Testing SSH Connections for context: ${YELLOW}$context${NC}\n"
    
    local hosts=()
    
    if [[ "$context" == "work" ]]; then
        hosts=("github.com-work" "gitlab.com-work")
    elif [[ "$context" == "personal" ]]; then
        hosts=("github.com-personal" "gitlab.com-personal")
    else
        echo -e "${RED}No context detected. Navigate to ~/work or ~/personal first.${NC}"
        return 1
    fi
    
    for host in "${hosts[@]}"; do
        echo -e "${YELLOW}Testing $host...${NC}"
        if ssh -T "$host" 2>&1 | grep -q "successfully authenticated\|Hi"; then
            echo -e "${GREEN}✓ $host - Connection successful!${NC}\n"
        else
            echo -e "${RED}✗ $host - Connection failed${NC}\n"
        fi
    done
}

# Function to list available contexts
list_contexts() {
    echo -e "${CYAN}Available SSH Contexts:${NC}\n"
    
    for context_dir in "$HOME/.ssh/keys"/*; do
        if [[ -d "$context_dir" ]]; then
            local context=$(basename "$context_dir")
            local key_file="$context_dir/id_ed25519"
            
            echo -e "${YELLOW}$context${NC}"
            
            if [[ -f "$key_file" ]]; then
                echo -e "  ${GREEN}✓${NC} SSH Key exists"
                echo -e "  Location: $key_file"
                
                # Show key fingerprint
                local fingerprint=$(ssh-keygen -lf "$key_file" 2>/dev/null | awk '{print $2}')
                echo -e "  Fingerprint: $fingerprint"
            else
                echo -e "  ${RED}✗${NC} SSH Key missing"
            fi
            
            # Check if config exists
            if [[ -f "$HOME/.ssh/config.$context" ]]; then
                echo -e "  ${GREEN}✓${NC} SSH Config exists"
            fi
            
            # Check if git config exists
            if [[ -f "$HOME/.gitconfig.$context" ]]; then
                echo -e "  ${GREEN}✓${NC} Git Config exists"
            fi
            
            echo ""
        fi
    done
}

# Function to switch context manually
switch_context() {
    local target_context=$1
    
    if [[ -z "$target_context" ]]; then
        echo -e "${RED}Error: Context name required${NC}"
        echo -e "Usage: ssh-context-manager switch <work|personal>"
        return 1
    fi
    
    local target_dir="$HOME/$target_context"
    
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}Error: Directory $target_dir does not exist${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Switching to $target_context context...${NC}"
    cd "$target_dir"
    
    # Reload direnv
    eval "$(direnv export bash)"
    
    echo -e "${GREEN}✓ Switched to $target_context context${NC}"
    show_status
}

# Function to add a new SSH key
add_key() {
    local context=$1
    
    if [[ -z "$context" ]]; then
        echo -e "${RED}Error: Context name required${NC}"
        echo -e "Usage: ssh-context-manager add-key <work|personal>"
        return 1
    fi
    
    local key_dir="$HOME/.ssh/keys/$context"
    local key_file="$key_dir/id_ed25519"
    
    mkdir -p "$key_dir"
    chmod 700 "$key_dir"
    
    if [[ -f "$key_file" ]]; then
        echo -e "${YELLOW}SSH key already exists for $context${NC}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    read -p "Enter email for $context SSH key: " email
    
    if [[ -z "$email" ]]; then
        echo -e "${RED}Error: Email required${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Generating SSH key for $context...${NC}"
    ssh-keygen -t ed25519 -C "$email" -f "$key_file"
    
    chmod 600 "$key_file"
    chmod 644 "$key_file.pub"
    
    echo -e "\n${GREEN}✓ SSH key generated successfully!${NC}\n"
    echo -e "${YELLOW}Public key:${NC}"
    cat "$key_file.pub"
    echo -e "\n${CYAN}Add this key to your Git hosting service${NC}"
}

# Function to smart clone
smart_clone() {
    local repo_url=$1
    
    if [[ -z "$repo_url" ]]; then
        echo -e "${RED}Error: Repository URL required${NC}"
        echo -e "Usage: ssh-context-manager clone <repository-url>"
        return 1
    fi
    
    local context=$(detect_context)
    
    if [[ "$context" == "none" ]]; then
        echo -e "${RED}Error: Not in a context directory${NC}"
        echo -e "Navigate to ~/work or ~/personal first"
        return 1
    fi
    
    # Modify URL to use context-specific host
    local modified_url=$repo_url
    
    if [[ "$repo_url" =~ git@github\.com: ]]; then
        modified_url="${repo_url/git@github.com:/git@github.com-$context:}"
    elif [[ "$repo_url" =~ git@gitlab\.com: ]]; then
        modified_url="${repo_url/git@gitlab.com:/git@gitlab.com-$context:}"
    fi
    
    echo -e "${GREEN}Cloning with $context context...${NC}"
    echo -e "URL: $modified_url"
    
    git clone "$modified_url"
}

# Function to show current configuration
show_config() {
    local context=$(detect_context)
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Current Configuration                                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${YELLOW}Detected Context:${NC} $context\n"
    
    echo -e "${YELLOW}SSH Configuration:${NC}"
    if [[ -f "$HOME/.ssh/config.$context" ]]; then
        cat "$HOME/.ssh/config.$context"
    else
        echo -e "${RED}No SSH config found for $context${NC}"
    fi
    
    echo -e "\n${YELLOW}Git Configuration:${NC}"
    if [[ -f "$HOME/.gitconfig.$context" ]]; then
        cat "$HOME/.gitconfig.$context"
    else
        echo -e "${RED}No Git config found for $context${NC}"
    fi
    
    echo -e "\n${YELLOW}Direnv Configuration:${NC}"
    local env_file="$HOME/$context/.envrc"
    if [[ -f "$env_file" ]]; then
        cat "$env_file"
    else
        echo -e "${RED}No .envrc found for $context${NC}"
    fi
}

# Main command router
main() {
    local command=${1:-status}
    
    case "$command" in
        status)
            show_status
            ;;
        test)
            test_connections
            ;;
        switch)
            switch_context "$2"
            ;;
        list)
            list_contexts
            ;;
        add-key)
            add_key "$2"
            ;;
        clone)
            smart_clone "$2"
            ;;
        config)
            show_config
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}\n"
            show_help
            exit 1
            ;;
    esac
}

main "$@"