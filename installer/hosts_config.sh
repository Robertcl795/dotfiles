#!/usr/bin/env bash
# installer/hosts_config.sh - Custom /etc/hosts entries

print_header "/etc/hosts Configuration"

echo >&2
if ! confirm "Add custom entries to /etc/hosts?" "n"; then
    print_info "Skipping /etc/hosts configuration"
    return 0
fi

echo >&2
print_info "Add custom host entries (format: IP hostname)"
print_info "Example: 127.0.0.1 myapp.local"
print_info "Leave empty and press Enter when done"
echo >&2

declare -a HOST_ENTRIES=()

while true; do
    read -p "Enter host entry (or press Enter to finish): " host_entry </dev/tty
    
    if [ -z "$host_entry" ]; then
        break
    fi
    
    # Validate format (IP address + hostname)
    if [[ $host_entry =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+[a-zA-Z0-9.-]+$ ]]; then
        HOST_ENTRIES+=("$host_entry")
        print_success "Added: $host_entry"
    else
        print_error "Invalid format. Use: IP hostname (e.g., 127.0.0.1 myapp.local)"
    fi
done

if [ ${#HOST_ENTRIES[@]} -eq 0 ]; then
    print_info "No entries to add"
    return 0
fi

echo >&2
print_info "Entries to add:"
for entry in "${HOST_ENTRIES[@]}"; do
    echo "  $entry" >&2
done

echo >&2
if ! confirm "Add these entries to /etc/hosts?" "y"; then
    print_info "Cancelled"
    return 0
fi

# Backup /etc/hosts
print_step "Creating backup of /etc/hosts..."
if sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S) >> "$DOTFILES_LOG" 2>&1; then
    print_success "Backup created"
else
    print_error "Failed to create backup"
    return 1
fi

# Add entries
print_step "Adding entries to /etc/hosts..."

# Create a temporary file with our additions
TEMP_FILE=$(mktemp)
echo "" >> "$TEMP_FILE"
echo "# Custom entries added by dotfiles installer" >> "$TEMP_FILE"
for entry in "${HOST_ENTRIES[@]}"; do
    echo "$entry" >> "$TEMP_FILE"
done

# Append to /etc/hosts
if sudo tee -a /etc/hosts < "$TEMP_FILE" > /dev/null 2>&1; then
    print_success "/etc/hosts updated"
    rm "$TEMP_FILE"
else
    print_error "Failed to update /etc/hosts"
    rm "$TEMP_FILE"
    return 1
fi

echo >&2
print_success "Added ${#HOST_ENTRIES[@]} entries to /etc/hosts"
echo >&2
