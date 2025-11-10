#!/usr/bin/env bash
# installer/k3d.sh - K3D and Helm installation

print_header "Kubernetes Development Tools"

# Check if Docker is available
if ! command_exists docker; then
    print_error "Docker is required for K3D but is not installed"
    print_info "Please install Docker first or enable it in the installer"
    return 1
fi

# Verify Docker is running
if ! docker ps &>/dev/null; then
    print_error "Docker is installed but not running"
    print_info "Please start Docker Desktop or run: sudo service docker start"
    return 1
fi

print_success "Docker is running"

# Install K3D
if ! command_exists k3d; then
    print_tool "K3D (Kubernetes in Docker)"
    print_step "Installing K3D..."
    
    if install_tool "k3d" "curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"; then
        K3D_VERSION=$(k3d version 2>/dev/null | grep k3d | awk '{print $3}' || echo "installed")
        print_info "K3D $K3D_VERSION"
    else
        print_error "Failed to install K3D"
        return 1
    fi
else
    print_tool "K3D"
    print_success "Already installed"
fi

# Install kubectl
if ! command_exists kubectl; then
    print_tool "kubectl"
    print_step "Installing kubectl..."
    
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    
    if run_silent "curl -LO \"https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl\"" && \
       run_silent "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl" && \
       run_silent "rm kubectl"; then
        
        if command_exists kubectl; then
            print_success "kubectl installed"
            KUBE_VERSION=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 || echo "$KUBECTL_VERSION")
            print_info "kubectl $KUBE_VERSION"
        fi
    else
        print_error "Failed to install kubectl"
        return 1
    fi
else
    print_tool "kubectl"
    print_success "Already installed"
fi

# Install Helm
if ! command_exists helm; then
    print_tool "Helm"
    print_step "Installing Helm..."
    
    if install_tool "helm" "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"; then
        HELM_VERSION=$(helm version --short 2>/dev/null | cut -d'+' -f1 || echo "installed")
        print_info "Helm $HELM_VERSION"
    else
        print_error "Failed to install Helm"
        return 1
    fi
else
    print_tool "Helm"
    print_success "Already installed"
fi

echo >&2
