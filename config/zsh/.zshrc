# ============================================================================
# ZSH Configuration with Zinit
# ============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR="vim"
export VISUAL="vim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ============================================================================
# Zinit Installation and Configuration
# ============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# Zinit Plugins
# ============================================================================

# Turbo mode - load plugins asynchronously
# Ref: https://github.com/zdharma-continuum/zinit#turbo-mode-zsh--53

# Load important plugins first (non-turbo)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Syntax highlighting (load early)
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    blockf \
        zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# FZF tab completion
zinit wait lucid for \
    Aloxaf/fzf-tab

# Useful snippets and plugins
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::kubectl \
    OMZP::helm \
    as"completion" \
        OMZP::docker/_docker

# ============================================================================
# History Configuration
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Write timestamp to history
setopt INC_APPEND_HISTORY        # Add commands immediately
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS      # Remove old duplicate entries
setopt HIST_REDUCE_BLANKS        # Remove unnecessary blanks
setopt HIST_VERIFY               # Show command before executing from history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first

# ============================================================================
# Completion Configuration
# ============================================================================

autoload -Uz compinit

# Only check compinit once per day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion options
setopt COMPLETE_IN_WORD    # Complete from both ends of word
setopt ALWAYS_TO_END       # Move cursor to end of word on completion
setopt PATH_DIRS           # Perform path search on commands with slashes
setopt AUTO_MENU           # Show completion menu on second tab
setopt AUTO_LIST           # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # Add trailing slash for directories
setopt NO_MENU_COMPLETE    # Don't autoselect first completion entry

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# FZF-tab configuration
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# ============================================================================
# Directory Navigation
# ============================================================================

setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push directories onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_MINUS          # Exchange meaning of + and -

# ============================================================================
# Modern CLI Tools Integration
# ============================================================================

# eza (modern ls)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias l='eza -lah --icons --group-directories-first'
fi

# bat (modern cat)
if command -v bat &> /dev/null; then
    alias cat='bat --style=auto'
    alias ccat='bat --style=plain'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# fd (modern find)
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# ripgrep (modern grep)
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# zoxide (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# fzf configuration
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
    
    # Use fd for fzf
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    
    # FZF colors and options
    export FZF_DEFAULT_OPTS="
        --height 40% --layout=reverse --border
        --preview '(bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -200'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'
    "
fi

# ============================================================================
# Version Managers
# ============================================================================

# mise (universal version manager for Node, Python, Rust)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
    eval "$(mise hook-env)"
fi

# direnv (environment variable manager)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# ============================================================================
# Docker and Kubernetes
# ============================================================================

# Docker aliases
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dimg='docker images'
    alias dprune='docker system prune -af'
fi

# K3D aliases
if command -v k3d &> /dev/null; then
    alias k3d-create='k3d cluster create dev --agents 2'
    alias k3d-delete='k3d cluster delete dev'
fi

# Kubectl aliases
if command -v kubectl &> /dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kl='kubectl logs'
    alias kx='kubectl exec -it'
    alias kd='kubectl describe'
fi

# Helm aliases
if command -v helm &> /dev/null; then
    alias h='helm'
    alias hl='helm list'
    alias hi='helm install'
    alias hu='helm upgrade'
fi

# ============================================================================
# Git Aliases
# ============================================================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --decorate --graph --all'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gst='git stash'
alias gstp='git stash pop'

# ============================================================================
# Angular Development Aliases
# ============================================================================

# pnpm aliases
if command -v pnpm &> /dev/null; then
    alias p='pnpm'
    alias pi='pnpm install'
    alias pa='pnpm add'
    alias pd='pnpm dev'
    alias pb='pnpm build'
    alias pt='pnpm test'
    alias pl='pnpm lint'
    alias pf='pnpm format'
    
    # Workspace commands
    alias pw='pnpm --filter'
    alias pr='pnpm -r'
fi

# Angular aliases
alias ng='pnpm exec ng'
alias ngs='pnpm exec ng serve'
alias ngb='pnpm exec ng build'
alias ngt='pnpm exec ng test'
alias ngg='pnpm exec ng generate'

# ============================================================================
# Utility Functions
# ============================================================================

# Create and enter directory
mkcd() {
    mkdir -p "$@" && cd "$_" || return
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
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

# Quick server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Find and kill process by port
killport() {
    lsof -ti:"$1" | xargs kill -9
}

# Git clone and cd
gcl() {
    git clone "$1" && cd "$(basename "$1" .git)" || return
}

# ============================================================================
# WSL Specific
# ============================================================================

# Open Windows Explorer in current directory
alias explorer='explorer.exe .'

# Access Windows home
alias winhome='cd /mnt/c/Users/$USER'

# ============================================================================
# Starship Prompt
# ============================================================================

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ============================================================================
# Load Local Configuration
# ============================================================================

# Load local zsh config if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
