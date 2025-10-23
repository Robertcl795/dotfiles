#!/bin/bash

# Test Script for Dotfiles Setup
# This script helps verify that the dotfiles installation works correctly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "\n${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

PASSED=0
FAILED=0

# Test 1: Check if ZSH is installed
print_test "Checking ZSH installation..."
if command -v zsh &> /dev/null; then
    print_pass "ZSH is installed"
    ((PASSED++))
else
    print_fail "ZSH is not installed"
    ((FAILED++))
fi

# Test 2: Check if Oh-My-Zsh is installed
print_test "Checking Oh-My-Zsh installation..."
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_pass "Oh-My-Zsh is installed"
    ((PASSED++))
else
    print_fail "Oh-My-Zsh is not installed"
    ((FAILED++))
fi

# Test 3: Check if direnv is installed
print_test "Checking direnv installation..."
if command -v direnv &> /dev/null; then
    print_pass "direnv is installed"
    ((PASSED++))
else
    print_fail "direnv is not installed"
    ((FAILED++))
fi

# Test 4: Check work directory structure
print_test "Checking work directory..."
if [[ -d "$HOME/work" ]]; then
    print_pass "~/work directory exists"
    ((PASSED++))
    if [[ -f "$HOME/work/.envrc" ]]; then
        print_pass "~/work/.envrc exists"
        ((PASSED++))
    else
        print_fail "~/work/.envrc does not exist"
        ((FAILED++))
    fi
else
    print_fail "~/work directory does not exist"
    ((FAILED++))
fi

# Test 5: Check personal directory structure
print_test "Checking personal directory..."
if [[ -d "$HOME/personal" ]]; then
    print_pass "~/personal directory exists"
    ((PASSED++))
    if [[ -f "$HOME/personal/.envrc" ]]; then
        print_pass "~/personal/.envrc exists"
        ((PASSED++))
    else
        print_fail "~/personal/.envrc does not exist"
        ((FAILED++))
    fi
else
    print_fail "~/personal directory does not exist"
    ((FAILED++))
fi

# Test 6: Check SSH directory structure
print_test "Checking SSH directory structure..."
if [[ -d "$HOME/.ssh/keys" ]]; then
    print_pass "~/.ssh/keys directory exists"
    ((PASSED++))
else
    print_fail "~/.ssh/keys directory does not exist"
    ((FAILED++))
fi

if [[ -d "$HOME/.ssh/keys/work" ]]; then
    print_pass "~/.ssh/keys/work directory exists"
    ((PASSED++))
else
    print_fail "~/.ssh/keys/work directory does not exist"
    ((FAILED++))
fi

if [[ -d "$HOME/.ssh/keys/personal" ]]; then
    print_pass "~/.ssh/keys/personal directory exists"
    ((PASSED++))
else
    print_fail "~/.ssh/keys/personal directory does not exist"
    ((FAILED++))
fi

# Test 7: Check SSH config files
print_test "Checking SSH config files..."
if [[ -f "$HOME/.ssh/config" ]]; then
    print_pass "~/.ssh/config exists"
    ((PASSED++))
else
    print_fail "~/.ssh/config does not exist"
    ((FAILED++))
fi

if [[ -f "$HOME/.ssh/config.work" ]]; then
    print_pass "~/.ssh/config.work exists"
    ((PASSED++))
else
    print_fail "~/.ssh/config.work does not exist"
    ((FAILED++))
fi

if [[ -f "$HOME/.ssh/config.personal" ]]; then
    print_pass "~/.ssh/config.personal exists"
    ((PASSED++))
else
    print_fail "~/.ssh/config.personal does not exist"
    ((FAILED++))
fi

# Test 8: Check Git config files
print_test "Checking Git config files..."
if [[ -f "$HOME/.gitconfig" ]]; then
    print_pass "~/.gitconfig exists"
    ((PASSED++))
else
    print_fail "~/.gitconfig does not exist"
    ((FAILED++))
fi

if [[ -f "$HOME/.gitconfig.work" ]]; then
    print_pass "~/.gitconfig.work exists"
    ((PASSED++))
else
    print_fail "~/.gitconfig.work does not exist"
    ((FAILED++))
fi

if [[ -f "$HOME/.gitconfig.personal" ]]; then
    print_pass "~/.gitconfig.personal exists"
    ((PASSED++))
else
    print_fail "~/.gitconfig.personal does not exist"
    ((FAILED++))
fi

# Test 9: Check if ssh-context-manager is accessible
print_test "Checking ssh-context-manager..."
if command -v ssh-context-manager &> /dev/null; then
    print_pass "ssh-context-manager is in PATH"
    ((PASSED++))
else
    print_fail "ssh-context-manager is not in PATH"
    ((FAILED++))
fi

# Test 10: Check modern CLI tools
print_test "Checking modern CLI tools..."
TOOLS=("eza" "bat" "rg" "fd" "fzf" "jq")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        print_pass "$tool is installed"
        ((PASSED++))
    else
        print_info "$tool is not installed (optional)"
    fi
done

# Summary
echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Tests Passed: $PASSED${NC}"
if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Tests Failed: $FAILED${NC}"
else
    echo -e "${GREEN}Tests Failed: $FAILED${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"

# Exit with appropriate code
if [[ $FAILED -gt 0 ]]; then
    echo -e "${YELLOW}Some tests failed. Please check the installation.${NC}"
    exit 1
else
    echo -e "${GREEN}All critical tests passed! ✨${NC}"
    exit 0
fi
