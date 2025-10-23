# ~/.zshrc - Enhanced ZSH Configuration with SSH Context Support

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-Zsh plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    helm
    terraform
    ansible
    aws
    node
    npm
    yarn
    python
    rust
    golang
    direnv
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# SSH Context Management
# ============================================================================

# Function to display current SSH context in prompt
ssh_context_info() {
    local context="${SSH_AUTH_SOCK_CONTEXT:-none}"
    
    if [[ "$context" != "none" ]]; then
        case "$context" in
            work)
                echo "%F{blue}🏢 WORK%f"
                ;;
            personal)
                echo "%F{green}🏠 PERSONAL%f"
                ;;
            *)
                echo "%F{yellow}⚠ $context%f"
                ;;
        esac
    fi
}

# Auto-load SSH keys when entering context directories
auto_load_ssh_keys() {
    local current_dir=$(pwd)
    
    # Check if we're in a work or personal directory
    if [[ "$current_dir" == "$HOME/work"* ]]; then
        local key_file="$HOME/.ssh/keys/work/id_ed25519"
        if [[ -f "$key_file" ]] && ! ssh-add -l | grep -q "$key_file"; then
            ssh-add "$key_file" 2>/dev/null
        fi
    elif [[ "$current_dir" == "$HOME/personal"* ]]; then
        local key_file="$HOME/.ssh/keys/personal/id_ed25519"
        if [[ -f "$key_file" ]] && ! ssh-add -l | grep -q "$key_file"; then
            ssh-add "$key_file" 2>/dev/null
        fi
    fi
}

# Hook to run on directory change
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_load_ssh_keys

# ============================================================================
# SSH Agent Management
# ============================================================================

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Use keychain for persistent SSH agent (optional, better for WSL)
if command -v keychain >/dev/null 2>&1; then
    # Only evaluate keychain if we have SSH keys
    if ls ~/.ssh/keys/*/id_ed25519 >/dev/null 2>&1; then
        eval "$(keychain --eval --quiet --agents ssh $(find ~/.ssh/keys -name 'id_ed25519' 2>/dev/null))"
    fi
fi

# ============================================================================
# Direnv Integration
# ============================================================================

# Hook direnv into shell
eval "$(direnv hook zsh)"

# Show direnv messages
export DIRENV_LOG_FORMAT=\033[0;36mdirenv:\033[0m %s'

# ============================================================================
# Environment Variables
# ============================================================================

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Development directories
export DEV_DIR="$HOME/dev"
export WORK_DIR="$HOME/work"
export PERSONAL_DIR="$HOME/personal"

# Language-specific
export GOPATH="$HOME/go"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

# FNM (Fast Node Manager)
if [[ -d "$HOME/.fnm" ]]; then
    export PATH="$HOME/.fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# Pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# ============================================================================
# Aliases
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias work='cd $WORK_DIR'
alias personal='cd $PERSONAL_DIR'
alias dev='cd $DEV_DIR'

# Modern CLI tools
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons --level=2'
else
    alias ll='ls -lah'
    alias la='ls -A'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=auto'
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --decorate --graph'
alias gclean='git clean -fd && git reset --hard'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kl='kubectl logs -f'
alias kex='kubectl exec -it'
alias kctx='kubectl config use-context'

# SSH Context Management
alias ssh-status='ssh-context-manager status'
alias ssh-test='ssh-context-manager test'
alias ssh-list='ssh-context-manager list'
alias ssh-config='ssh-context-manager config'
alias sshc='ssh-context-manager'

# Quick context switching
alias go-work='cd $WORK_DIR && direnv allow'
alias go-personal='cd $PERSONAL_DIR && direnv allow'

# System
alias reload='source ~/.zshrc'
alias editrc='code ~/.zshrc'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'

# ============================================================================
# Functions
# ============================================================================

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Clone and enter repository (context-aware)
gclone() {
    if [[ -z "$1" ]]; then
        echo "Usage: gclone <repository-url>"
        return 1
    fi
    
    ssh-context-manager clone "$1"
    
    # Extract repo name and cd into it
    local repo_name=$(basename "$1" .git)
    cd "$repo_name" 2>/dev/null || true
}

# Create a new project in current context
new-project() {
    local project_name=$1
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: new-project <project-name>"
        return 1
    fi
    
    local current_dir=$(pwd)
    local context="none"
    
    if [[ "$current_dir" == "$WORK_DIR"* ]]; then
        context="work"
    elif [[ "$current_dir" == "$PERSONAL_DIR"* ]]; then
        context="personal"
    else
        echo "Error: Not in a context directory (work/personal)"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    git init
    echo "# $project_name" > README.md
    echo "node_modules/" > .gitignore
    echo "dist/" >> .gitignore
    echo ".env" >> .gitignore
    echo ".DS_Store" >> .gitignore
    
    git add .
    git commit -m "Initial commit"
    
    echo "✓ New $context project created: $project_name"
}

# Show current environment info
envinfo() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  Environment Information                                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Current Directory: $(pwd)"
    echo "Context: ${SSH_AUTH_SOCK_CONTEXT:-none}"
    echo ""
    echo "Node: $(node --version 2>/dev/null || echo 'not installed')"
    echo "Python: $(python --version 2>/dev/null || echo 'not installed')"
    echo "Go: $(go version 2>/dev/null | awk '{print $3}' || echo 'not installed')"
    echo "Rust: $(rustc --version 2>/dev/null | awk '{print $2}' || echo 'not installed')"
    echo ""
    echo "Docker: $(docker --version 2>/dev/null || echo 'not installed')"
    echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'not installed')"
    echo ""
    echo "Git User: $(git config user.name) <$(git config user.email)>"
    echo ""
}

# Quick search in project
search() {
    if command -v rg >/dev/null 2>&1; then
        rg --smart-case --hidden --glob '!.git' "$@"
    else
        grep -r "$@" .
    fi
}

# Find file by name
findfile() {
    if command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --exclude .git "$@"
    else
        find . -type f -name "*$@*"
    fi
}

# Extract archives
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Port killer
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    
    local pid=$(lsof -ti:$1)
    if [[ -n "$pid" ]]; then
        kill -9 $pid
        echo "Killed process on port $1"
    else
        echo "No process found on port $1"
    fi
}

# Docker cleanup helper
docker-cleanup() {
    echo "Removing stopped containers..."
    docker container prune -f
    
    echo "Removing dangling images..."
    docker image prune -f
    
    echo "Removing unused volumes..."
    docker volume prune -f
    
    echo "Removing unused networks..."
    docker network prune -f
    
    echo "✓ Docker cleanup complete"
}

# K3D cluster management
k3d-start() {
    local cluster_name=${1:-dev}
    
    if k3d cluster list | grep -q "$cluster_name"; then
        echo "Starting cluster: $cluster_name"
        k3d cluster start "$cluster_name"
    else
        echo "Creating cluster: $cluster_name"
        k3d cluster create "$cluster_name" \
            --api-port 6443 \
            --servers 1 \
            --agents 2 \
            --port "8080:80@loadbalancer"
    fi
    
    kubectl config use-context "k3d-$cluster_name"
}

k3d-stop() {
    local cluster_name=${1:-dev}
    echo "Stopping cluster: $cluster_name"
    k3d cluster stop "$cluster_name"
}

k3d-delete() {
    local cluster_name=${1:-dev}
    echo "Deleting cluster: $cluster_name"
    k3d cluster delete "$cluster_name"
}

# ============================================================================
# SSH Context Display in Prompt (if not using P10k)
# ============================================================================

# If you want to add SSH context to a custom prompt
# RPROMPT='$(ssh_context_info)'

# ============================================================================
# Completion Enhancements
# ============================================================================

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Color completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Cache completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ============================================================================
# History Configuration
# ============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't display duplicates
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt SHARE_HISTORY             # Share history between sessions

# ============================================================================
# Key Bindings
# ============================================================================

# Use emacs key bindings
bindkey -e

# Ctrl+Arrow keys
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Delete key
bindkey "^[[3~" delete-char

# ============================================================================
# Welcome Message
# ============================================================================

# Display context info on shell start (only for interactive shells)
if [[ -o interactive ]]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  Welcome back! 👋                                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Show SSH context if in a context directory
    local current_context="${SSH_AUTH_SOCK_CONTEXT:-none}"
    if [[ "$current_context" != "none" ]]; then
        echo "📍 Current context: $current_context"
        echo ""
    fi
    
    # Quick tips
    echo "💡 Quick commands:"
    echo "   • ssh-status  - Check SSH context"
    echo "   • envinfo     - Show environment info"
    echo "   • work        - Go to work directory"
    echo "   • personal    - Go to personal directory"
    echo ""
fi

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh