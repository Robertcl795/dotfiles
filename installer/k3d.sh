#!/usr/bin/env bash
# installer/k3d.sh - K3D and Helm installation

print_header "Kubernetes Development Tools"

# Check if Docker is available
if ! command_exists docker; then
    print_error "Docker is required for K3D but is not installed"
    print_info "Please install Docker first or enable it in the installer"
    exit 1
fi

# Install K3D
if ! command_exists k3d; then
    print_tool "K3D (Kubernetes in Docker)"
    print_step "Installing K3D..."
    
    if run_silent "curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"; then
        print_success "K3D installed"
    else
        print_error "Failed to install K3D"
        exit 1
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
    
    if run_silent "curl -LO \"https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl\" && \
                   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
                   rm kubectl"; then
        print_success "kubectl installed"
    else
        print_error "Failed to install kubectl"
        exit 1
    fi
else
    print_tool "kubectl"
    print_success "Already installed"
fi

# Install Helm
if ! command_exists helm; then
    print_tool "Helm"
    print_step "Installing Helm..."
    
    if run_silent "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"; then
        print_success "Helm installed"
    else
        print_error "Failed to install Helm"
        exit 1
    fi
else
    print_tool "Helm"
    print_success "Already installed"
fi

# Verify installations
if k3d version &>/dev/null; then
    K3D_VERSION=$(k3d version | grep k3d | awk '{print $3}')
    print_info "K3D version: $K3D_VERSION"
fi

if kubectl version --client &>/dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)
    print_info "kubectl version: $KUBECTL_VERSION"
fi

if helm version &>/dev/null; then
    HELM_VERSION=$(helm version --short | cut -d'+' -f1)
    print_info "Helm version: $HELM_VERSION"
fi

echo