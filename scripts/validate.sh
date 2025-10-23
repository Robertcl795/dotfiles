#!/bin/bash

# Pre-commit validation script
# Ensures scripts are executable and have proper shebangs

set -e

echo "🔍 Running pre-commit validation..."

# Check if all shell scripts have proper permissions
echo "Checking script permissions..."
scripts=(
    "bootstrap.sh"
    "install.sh"
    "update.sh"
    "uninstall.sh"
    "test.sh"
    "configure.sh"
    "quick-setup.sh"
    "bin/ssh-context-manager.sh"
    "scripts/setup/setup-zsh.sh"
    "scripts/setup/install-dev-tools.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ ! -x "$script" ]]; then
            echo "⚠️  $script is not executable, fixing..."
            chmod +x "$script"
        fi
        echo "✓ $script"
    fi
done

# Check for shebang in scripts
echo ""
echo "Checking shebangs..."
for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        if ! head -n 1 "$script" | grep -q "^#!/bin/bash"; then
            echo "❌ $script missing or incorrect shebang"
            exit 1
        fi
    fi
done

echo "✓ All scripts have correct shebangs"

# Validate template files exist
echo ""
echo "Checking template files..."
templates=(
    "templates/.envrc.work"
    "templates/.envrc.personal"
    "templates/ssh-config.main"
    "templates/ssh-config.work"
    "templates/ssh-config.personal"
)

for template in "${templates[@]}"; do
    if [[ ! -f "$template" ]]; then
        echo "❌ Missing: $template"
        exit 1
    fi
    echo "✓ $template"
done

# Validate config files exist
echo ""
echo "Checking config files..."
configs=(
    "config/.zshrc"
    "config/.gitconfig"
    "config/.gitconfig.work"
    "config/.gitconfig.personal"
    "config/.gitignore_global"
    "config/.zsh_aliases"
    "config/.zsh_functions"
)

for config in "${configs[@]}"; do
    if [[ ! -f "$config" ]]; then
        echo "❌ Missing: $config"
        exit 1
    fi
    echo "✓ $config"
done

# Check documentation files
echo ""
echo "Checking documentation..."
docs=(
    "README.md"
    "QUICKSTART.md"
    "IMPLEMENTATION.MD"
    "EXAMPLES.md"
    "FAQ.md"
    "TROUBLESHOOTING.MD"
    "WSL-SPECIFIC.MD"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    "STRUCTURE.md"
    "SUMMARY.md"
)

for doc in "${docs[@]}"; do
    if [[ ! -f "$doc" ]]; then
        echo "⚠️  Missing: $doc (optional)"
    else
        echo "✓ $doc"
    fi
done

echo ""
echo "✅ All pre-commit checks passed!"
