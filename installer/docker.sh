#!/usr/bin/env bash
# installer/docker.sh - Docker tools setup

print_header "Docker Tools"

# Check if Docker is accessible
if command_exists docker; then
    print_tool "Docker"
    
    # Try to verify Docker is actually running
    if docker ps &>/dev/null; then
        print_success "Docker is installed and running"
        DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
        print_info "$DOCKER_VERSION"
    else
        print_warning "Docker is installed but not running"
        print_info "Start Docker Desktop or run: sudo service docker start"
    fi
else
    print_tool "Docker"
    print_warning "Docker not found"
    print_info "Install Docker Desktop with WSL2 backend"
    print_info "Visit: https://docs.docker.com/desktop/windows/wsl/"
    echo >&2
fi

# Check for docker-compose (v2 is usually bundled with Docker Desktop)
if command_exists docker-compose || docker compose version &>/dev/null; then
    print_tool "Docker Compose"
    print_success "Already available"
else
    print_tool "Docker Compose"
    
    if command_exists docker && docker compose version &>/dev/null; then
        print_success "Available as 'docker compose'"
    else
        print_warning "Docker Compose not found"
        print_info "It's usually included with Docker Desktop"
    fi
fi

echo >&2
