← [Previous: Troubleshooting](04-TROUBLESHOOTING.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: Structure →](06-STRUCTURE.md)

---

# 🪟 WSL-Specific Configuration Guide

## WSL-Specific Optimizations

### SSH Agent Persistence in WSL

WSL doesn't persist the SSH agent between sessions by default. Here's how to fix that:

#### Option 1: Using Keychain (Recommended)

Already included in bootstrap.sh, but here's manual setup:

```bash
# Install keychain
sudo apt install keychain

# Add to ~/.zshrc (already in our config)
if command -v keychain >/dev/null 2>&1; then
    eval $(keychain --eval --quiet --agents ssh \
        ~/.ssh/keys/work/id_ed25519 \
        ~/.ssh/keys/personal/id_ed25519)
fi
```

#### Option 2: Windows SSH Agent Integration

Use Windows' native SSH agent from WSL:

```bash
# Install socat
sudo apt install socat

# Add to ~/.zshrc
# Use Windows SSH Agent
if command -v socat >/dev/null 2>&1; then
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
        rm -f "$SSH_AUTH_SOCK"
        (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
fi
```

### WSL-Specific .wslconfig

Create `C:\Users\YOUR_USERNAME\.wslconfig`:

```ini
[wsl2]
# Limit memory
memory=8GB
# Limit processors
processors=4
# Enable swap
swap=2GB
# Disable page reporting
pageReporting=false
# Network mode
networkingMode=mirrored
# DNS tunneling
dnsTunneling=true
# Firewall
firewall=true
```

### Git Credential Manager Integration

Link WSL Git with Windows Git Credential Manager:

```bash
# Configure Git to use Windows Credential Manager
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"

# Or use the newer version
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
```

### VS Code Integration

Enhanced VS Code integration for WSL:

```bash
# Install VS Code server components
code --install-extension ms-vscode-remote.remote-wsl

# Create alias for opening VS Code from WSL
echo 'alias code="/mnt/c/Users/YOUR_USERNAME/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code"' >> ~/.zshrc

# Open current directory in VS Code
code .
```

### Docker Desktop Integration

Ensure Docker Desktop is properly integrated:

```bash
# Add to ~/.zshrc
# Docker Desktop for Windows integration
if [ -S /var/run/docker.sock ]; then
    export DOCKER_HOST="unix:///var/run/docker.sock"
fi

# Or if using Docker Desktop's WSL integration
if [ -n "$WSL_DISTRO_NAME" ]; then
    export DOCKER_HOST="npipe:////./pipe/docker_engine"
fi
```

### Windows Path Integration

Selectively add Windows tools to PATH:

```bash
# Add to ~/.zshrc
# Windows integration - selectively add useful Windows tools
export PATH="$PATH:/mnt/c/Windows/System32"
export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"

# Create aliases for common Windows tools
alias explorer='explorer.exe'
alias notepad='notepad.exe'
alias clip='clip.exe'

# Copy to Windows clipboard
alias pbcopy='clip.exe'

# Function to convert WSL path to Windows path
wslpath() {
    wslpath -w "$1"
}
```

### Performance Optimizations

#### Exclude WSL directories from Windows Defender

Create `exclude-wsl-from-defender.ps1` (run in PowerShell as Admin):

```powershell
# Exclude WSL directories from Windows Defender
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu\home"
Add-MpPreference -ExclusionPath "C:\Users\YOUR_USERNAME\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*"

# Exclude common development directories
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu\home\YOUR_USERNAME\work"
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu\home\YOUR_USERNAME\personal"
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu\home\YOUR_USERNAME\.dotfiles"

# Verify exclusions
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
```

#### Optimize file operations

```bash
# Add to ~/.zshrc
# Optimize file operations in WSL
export DONT_PROMPT_WSL_INSTALL=1

# Use /tmp for temporary files (faster in WSL)
export TMPDIR=/tmp
```

### Enhanced WSL Bootstrap Script

Create `bootstrap-wsl.sh` for WSL-specific setup:

```bash
#!/bin/bash

# WSL-Specific Bootstrap Script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting WSL-specific setup...${NC}"

# 1. Update WSL
echo -e "${GREEN}Updating WSL...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Install WSL-specific packages
echo -e "${GREEN}Installing WSL utilities...${NC}"
sudo apt install -y \
    keychain \
    socat \
    wslu

# 3. Configure Git for WSL
echo -e "${GREEN}Configuring Git for WSL...${NC}"
git config --global core.fileMode false
git config --global core.autocrlf input

# 4. Setup Windows interop
echo -e "${GREEN}Configuring Windows interop...${NC}"
cat >> ~/.zshrc << 'EOF'

# WSL-specific configuration
if grep -q microsoft /proc/version; then
    # Windows path integration
    export PATH="$PATH:/mnt/c/Windows/System32"
    export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"
    
    # Windows aliases
    alias explorer='explorer.exe'
    alias pbcopy='clip.exe'
    
    # Open current directory in Windows Explorer
    alias open='explorer.exe .'
fi
EOF

# 5. Create Windows shortcuts
echo -e "${GREEN}Creating Windows shortcuts...${NC}"
mkdir -p ~/bin

# Script to open current directory in VS Code
cat > ~/bin/code-here << 'EOF'
#!/bin/bash
code "$(wslpath -w $(pwd))"
EOF
chmod +x ~/bin/code-here

# Script to open current directory in Windows Explorer
cat > ~/bin/explorer-here << 'EOF'
#!/bin/bash
explorer.exe "$(wslpath -w $(pwd))"
EOF
chmod +x ~/bin/explorer-here

# 6. Setup systemd (if supported)
if command -v systemctl >/dev/null 2>&1; then
    echo -e "${GREEN}Enabling systemd in WSL...${NC}"
    sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[boot]
systemd=true

[automount]
enabled = true
options = "metadata,umask=22,fmask=11"

[network]
generateResolvConf = true
EOF
fi

echo -e "${GREEN}WSL-specific setup complete!${NC}"
echo -e "${BLUE}Please restart WSL for changes to take effect${NC}"
```

### Directory Structure Best Practices for WSL

```bash
# Create optimized directory structure
mkdir -p ~/work
mkdir -p ~/personal
mkdir -p ~/dev/tools
mkdir -p ~/dev/playground

# Link to Windows directories (optional)
ln -s /mnt/c/Users/YOUR_USERNAME/Documents ~/windows-docs
ln -s /mnt/c/Users/YOUR_USERNAME/Downloads ~/windows-downloads

# Keep project files in WSL filesystem for better performance
# Avoid working directly in /mnt/c/ - it's slower
```

### SSH Key Management in WSL

Enhanced `.envrc` with WSL optimizations:

```bash
# ~/work/.envrc
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work"
export SSH_AUTH_SOCK_CONTEXT="work"

# WSL-specific: Use keychain for persistent SSH agent
if command -v keychain >/dev/null 2>&1; then
    eval $(keychain --eval --quiet --agents ssh ~/.ssh/keys/work/id_ed25519)
else
    # Fallback to regular ssh-agent
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        eval "$(ssh-agent -s)"
    fi
    ssh-add ~/.ssh/keys/work/id_ed25519 2>/dev/null || true
fi

echo "🏢 Switched to WORK environment (WSL-optimized)"
```

### WSL Backup Script

Create `backup-wsl.sh`:

```bash
#!/bin/bash

# Backup WSL environment
BACKUP_DIR="/mnt/c/Users/$USER/WSL-Backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup SSH keys
tar -czf "$BACKUP_DIR/ssh-keys-$DATE.tar.gz" ~/.ssh/keys/

# Backup dotfiles
tar -czf "$BACKUP_DIR/dotfiles-$DATE.tar.gz" ~/.dotfiles/

# Backup important configs
tar -czf "$BACKUP_DIR/configs-$DATE.tar.gz" \
    ~/.gitconfig* \
    ~/.zshrc \
    ~/.ssh/config* \
    ~/work/.envrc \
    ~/personal/.envrc

# Export WSL distro (full backup)
echo "Exporting WSL distro to $BACKUP_DIR/wsl-full-$DATE.tar"
echo "This may take a while..."
# Run this from PowerShell:
# wsl --export Ubuntu "$BACKUP_DIR\\wsl-full-$DATE.tar"

echo "✅ Backup complete: $BACKUP_DIR"
```

### Performance Monitoring

Create `wsl-status.sh`:

```bash
#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  WSL System Status                                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# WSL version
echo "📦 WSL Version:"
wsl.exe --version 2>/dev/null || echo "WSL 1"
echo ""

# Distro info
echo "🐧 Distribution:"
cat /etc/os-release | grep PRETTY_NAME
echo ""

# Memory usage
echo "💾 Memory Usage:"
free -h
echo ""

# Disk usage
echo "💿 Disk Usage:"
df -h / | tail -1
echo ""

# Docker status
echo "🐳 Docker Status:"
if command -v docker >/dev/null 2>&1; then
    docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "Docker not running"
else
    echo "Docker not installed"
fi
echo ""

# SSH agent status
echo "🔐 SSH Agent Status:"
if ssh-add -l &>/dev/null; then
    ssh-add -l
else
    echo "No SSH keys loaded"
fi
echo ""

# Current context
echo "📍 Current Context:"
echo "Directory: $(pwd)"
echo "SSH Context: ${SSH_AUTH_SOCK_CONTEXT:-none}"
echo "Git Email: $(git config user.email)"
```

### Quick WSL Commands Reference

```bash
# Restart WSL (from PowerShell)
wsl --shutdown

# List installed distros
wsl --list --verbose

# Set default distro
wsl --set-default Ubuntu

# Export distro
wsl --export Ubuntu C:\backup\ubuntu.tar

# Import distro
wsl --import Ubuntu C:\WSL\Ubuntu C:\backup\ubuntu.tar

# Unregister distro
wsl --unregister Ubuntu

# Update WSL kernel
wsl --update
```

### Troubleshooting WSL Issues

#### Issue: Slow file operations

```bash
# Solution: Work in WSL filesystem, not /mnt/c/
cd ~  # Fast
cd /mnt/c/Users/...  # Slow - avoid for development

# If you must access Windows files:
# Use selective sync or copy to WSL filesystem first
```

#### Issue: DNS resolution problems

```bash
# Edit /etc/resolv.conf
sudo tee /etc/resolv.conf > /dev/null << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# Prevent auto-generation
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[network]
generateResolvConf = false
EOF
```

#### Issue: Port forwarding not working

```bash
# From PowerShell (as Admin), forward ports:
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=$(wsl hostname -I)

# List forwarded ports
netsh interface portproxy show all

# Delete port forwarding
netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=0.0.0.0
```

## Complete WSL Installation Flow

### 1. Install WSL (PowerShell as Admin)

```powershell
# Install WSL
wsl --install

# Or install specific distro
wsl --install -d Ubuntu

# Restart computer
```

### 2. First Boot Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git curl wget
```

### 3. Run Bootstrap

```bash
# Run the bootstrap script
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)

# Run WSL-specific setup
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap-wsl.sh)
```

### 4. Configure Windows Integration

```bash
# Install Windows Terminal (from Microsoft Store)
# Configure Windows Terminal to use WSL as default

# Configure VS Code Remote-WSL extension
code --install-extension ms-vscode-remote.remote-wsl
```

### 5. Done!

```bash
# Test everything
ssh-status
envinfo
wsl-status
```

---

**🎉 Your WSL environment is now fully configured with context-aware SSH management!**