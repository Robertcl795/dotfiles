#!/usr/bin/env bash
# installer/wsl_config.sh - WSL configuration for K3D and Windows integration

print_header "WSL Configuration"

print_tool "WSL Config"

# Check if running in WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    print_warning "Not running in WSL, skipping WSL configuration"
    exit 0
fi

print_step "Configuring /etc/wsl.conf for K3D and Windows integration..."

# Create or update /etc/wsl.conf
WSL_CONF="/etc/wsl.conf"

# Check if wsl.conf exists and backup
if [ -f "$WSL_CONF" ]; then
    print_info "Backing up existing wsl.conf..."
    sudo cp "$WSL_CONF" "$WSL_CONF.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create the wsl.conf content
sudo tee "$WSL_CONF" > /dev/null << 'EOF'
# WSL Configuration for K3D and Windows Integration
# Requires WSL restart: wsl --shutdown (run from PowerShell/CMD)

[boot]
# Enable systemd for proper service management (required for K3D)
systemd=true

[network]
# Generate /etc/hosts automatically
generateHosts=true
# Generate /etc/resolv.conf for DNS
generateResolvConf=true

[interop]
# Enable Windows interoperability
enabled=true
# Append Windows PATH to WSL PATH
appendWindowsPath=true

[automount]
# Enable automatic mounting of Windows drives
enabled=true
# Mount Windows drives at /mnt/
root=/mnt/
# Mount options for better performance
options="metadata,umask=22,fmask=11"

[user]
# Set default user (optional, uncomment and set your username)
# default=your-username
EOF

if [ $? -eq 0 ]; then
    print_success "WSL configuration created"
    echo >&2
    print_warning "IMPORTANT: WSL restart required for changes to take effect"
    print_info "From PowerShell/CMD, run: ${BOLD}wsl --shutdown${NC}"
    print_info "Then restart your WSL instance"
    echo >&2
    print_info "Configuration details:"
    echo "  • Systemd enabled (required for K3D)" >&2
    echo "  • Windows interoperability enabled" >&2
    echo "  • Windows PATH appended to WSL" >&2
    echo "  • Automatic /etc/hosts and DNS generation" >&2
else
    print_error "Failed to create WSL configuration"
    return 1
fi

echo >&2
