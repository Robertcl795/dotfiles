← [Previous: Quick Start](01-QUICKSTART.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: FAQ →](03-FAQ.md)

---

# Examples - Practical Use Cases

This document provides real-world examples of using the context-aware dotfiles system.

## 🎯 Daily Workflows

### Starting a Work Day

```bash
# Navigate to work directory - context switches automatically
cd ~/work

# Verify context
ssh-status
# Output: 🏢 WORK context active

# Clone a work repository
git clone git@github.com-work:company/project.git

# Or use the smart clone function
gclone git@github.com:company/project.git

# Start working
cd project
git-whoami
# Output:
# Git Configuration:
#   Name:  Your Work Name
#   Email: you@company.com
# SSH Context: work
```

### Working on Personal Projects

```bash
# Switch to personal directory
cd ~/personal

# Verify context switch
ssh-status
# Output: 🏠 PERSONAL context active

# Clone personal repository
gclone git@github.com:username/my-project.git

# Create a new personal project
new-project my-new-idea

# Verify Git configuration
git-whoami
# Output:
# Git Configuration:
#   Name:  Your Personal Name
#   Email: your.personal@email.com
# SSH Context: personal
```

## 📂 Project Management

### Creating a New Work Project

```bash
# Go to work directory
cd ~/work

# Create and initialize new project
new-project awesome-feature

# Project is automatically created with:
# - Git initialized
# - README.md
# - .gitignore
# - Work Git config loaded

# Add remote and push
git remote add origin git@github.com-work:company/awesome-feature.git
gpush  # Pushes to origin with work credentials
```

### Quick Commits and Pushes

```bash
# Make changes to files
echo "console.log('Hello World');" > index.js

# Quick commit all changes
gcam "Add hello world functionality"

# Push current branch
gpush

# Or traditional way
git add .
git commit -m "Add feature"
git push origin $(git branch --show-current)
```

## 🔑 SSH Key Management

### Checking Current SSH Configuration

```bash
# Show current context and loaded keys
ssh-status

# Show detailed SSH and Git configuration
ssh-config

# Test SSH connections
ssh-test
```

### Switching Contexts Manually (if needed)

```bash
# Switch to work context
ssh-switch work

# Switch to personal context
ssh-switch personal

# Note: Usually automatic with direnv when changing directories
```

## 🔄 Git Workflows

### Feature Branch Workflow

```bash
cd ~/work/project

# Create feature branch
gcb feature/new-feature
# Same as: git checkout -b feature/new-feature

# Make changes and commit
gcam "Implement new feature"

# Push feature branch
gpush

# View branch history
gl  # Short log
gla # Full log with all branches
```

### Reviewing Changes

```bash
# Show working directory status
gs  # git status

# Show changes not yet staged
gd  # git diff

# Show staged changes
gdc # git diff --cached

# Show pretty log
gl  # git log --oneline --graph
```

### Stashing Work

```bash
# Stash current work
gst  # git stash

# Apply last stash
gstp # git stash pop

# List all stashes
git stash list
```

## 🛠️ Development Tools

### Using Modern CLI Tools

```bash
# List files with eza (modern ls)
ls      # Shows icons and colors
ll      # Detailed list with git status
la      # List all including hidden
lt      # Tree view

# View file contents with bat (modern cat)
cat README.md  # Syntax highlighted output

# Search with ripgrep (modern grep)
rg "TODO"      # Search for TODO in all files

# Find files with fd (modern find)
fd "config"    # Find files matching "config"

# Fuzzy search with fzf
# Press Ctrl+R for command history search
# Press Ctrl+T for file search
```

### Docker Workflows

```bash
# View running containers
dps

# View all containers
dpsa

# View images
di

# Execute command in container
dex container_name bash

# View logs
dlog container_name

# Stop all containers
docker-stop-all

# Clean up Docker
docker-clean
```

### Kubernetes Workflows

```bash
# Get resources
kg pods
kg services
kg deployments

# Describe resource
kd pod my-pod

# View logs
kl pod-name
klf pod-name  # Follow logs

# Execute command in pod
kex pod-name -- /bin/bash

# Switch context
kctx production

# Switch namespace
kns my-namespace
```

## 📁 File Operations

### Navigation

```bash
# Quick jump to work
work           # cd ~/work
work project1  # cd ~/work/project1

# Quick jump to personal
personal       # cd ~/personal
personal blog  # cd ~/personal/blog

# Go up multiple directories
up 3   # Go up 3 levels

# Create and enter directory
mkcd new-folder  # mkdir + cd
```

### File Search and Management

```bash
# Find files by name
ff "README"     # Finds all files containing "README"

# Find directories
fd "config"     # Finds all directories containing "config"

# Extract archives
extract archive.tar.gz
extract project.zip

# Check directory size
dirsize .
dirsize ~/Downloads

# Analyze disk usage
usage  # Interactive with ncdu if available
```

## 🌐 Network Operations

```bash
# Get local IP
localip

# Get external IP
myip

# Test internet connection
nettest

# Show open ports
ports

# Check weather
weather
```

## 📝 Notes and Utilities

```bash
# Quick note taking
note "Remember to update documentation"
note "Bug in authentication module"

# View all notes
notes

# Create backup of file
backup important-config.json
# Creates: important-config.json.backup-20251022-143022

# Start local HTTP server
serve       # Default port 8000
serve 3000  # Custom port
```

## 🔄 Updating and Maintenance

### Updating Dotfiles

```bash
# Update dotfiles and all dependencies
make update
# Or: ./update.sh

# Test installation
make test
# Or: ./test.sh
```

### Customization

```bash
# Edit ZSH config
zshrc

# Edit aliases
aliases

# Edit functions
functions

# Edit Git config
gitconfig

# Reload shell config
reload
# Or: source ~/.zshrc
```

## 🎨 Terminal Customization

### Viewing Git History

```bash
# Beautiful git log
gl   # Current branch
gla  # All branches

# Example output:
# * a1b2c3d - (HEAD -> main) Add feature (2 hours ago) <Your Name>
# * e4f5g6h - Fix bug (1 day ago) <Your Name>
# * i7j8k9l - Initial commit (2 days ago) <Your Name>
```

### Command History

```bash
# View most used commands
hist-stats

# Search command history with fzf
# Press Ctrl+R
```

## 🚀 Advanced Examples

### Multi-Context Workflow

```bash
# Morning: Work on company project
cd ~/work/company-api
gpl  # Pull latest changes
gcb feature/user-auth
# ... make changes ...
gcam "Implement user authentication"
gpush

# Lunch break: Blog post
cd ~/personal/blog
new-project "post-dotfiles-setup"
# ... write blog post ...
gcam "Draft dotfiles setup guide"
gpush

# Afternoon: Back to work
cd ~/work/company-api
# Context automatically switches back to work
# ... continue working ...
```

### Setting Up New Machine

```bash
# One command to rule them all
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)

# Follow prompts, then:
# 1. Edit ~/.gitconfig.work
# 2. Edit ~/.gitconfig.personal
# 3. Add SSH keys to GitHub
# 4. Start working!
```

### Debugging Context Issues

```bash
# Check current context
echo $SSH_AUTH_SOCK_CONTEXT

# Check loaded SSH keys
ssh-add -l

# Check Git configuration
git config --list --show-origin

# Test SSH connection
ssh -T git@github.com-work
ssh -T git@github.com-personal

# Full diagnostic
ssh-status
ssh-test
ssh-config
```

## 💡 Tips and Tricks

### Productivity Boosters

1. **Use aliases**: Instead of typing full commands, use shortcuts
   ```bash
   gs    # Instead of git status
   gco   # Instead of git checkout
   dps   # Instead of docker ps
   ```

2. **Leverage functions**: Use smart functions for common tasks
   ```bash
   gclone <url>         # Smart clone with context
   new-project <name>   # Create and initialize project
   work <project>       # Quick jump to work project
   ```

3. **FZF shortcuts**:
   - `Ctrl+R`: Search command history
   - `Ctrl+T`: Search files
   - `Alt+C`: Search directories

4. **Directory markers**: Use `z` or `autojump` with your favorite directories

### Common Patterns

```bash
# Quick feature implementation
cd ~/work/project
gcb feature/quick-fix
# ... make changes ...
gcam "Quick fix for issue #123"
gpush

# Review before committing
gs    # Check status
gd    # Review changes
ga .  # Stage all
gc    # Commit with editor (for detailed message)
```

---

**Remember**: Context switching is automatic when you navigate between `~/work` and `~/personal` directories. The right SSH keys and Git configs are loaded automatically! 🎉
