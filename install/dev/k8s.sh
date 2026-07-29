#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH="$PWD"
fi
SCRIPT_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/../common.sh"
DOT_ENABLE_K8S="${DOT_ENABLE_K8S:-1}"

install_kubectl() {
  if ensure_cmd kubectl; then
    return 0
  fi
  local arch
  arch="$(detect_arch)"
  local version
  version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSL "https://dl.k8s.io/release/${version}/bin/linux/${arch}/kubectl" -o /tmp/kubectl
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
}

install_helm() {
  if ensure_cmd helm; then
    return 0
  fi
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_k3d() {
  if ensure_cmd k3d; then
    return 0
  fi
  curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

install_k8s_tools() {
  if ! any_tool_selected kubectl helm k3d; then
    log_info "Phase 6: no Kubernetes tooling selected, skipping."
    return 0
  fi
  log_step "Phase 6: Dev environment (k8s)"
  tool_selected kubectl && install_kubectl
  tool_selected helm && install_helm
  tool_selected k3d && install_k3d
  return 0
}

if [ "${1:-}" = "--run" ]; then
  install_k8s_tools
fi
