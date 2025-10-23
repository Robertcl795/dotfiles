← [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: Examples →](02-EXAMPLES.md)

---

# 🚀 Quick Start Guide - Context-Aware SSH Setup

## Fresh WSL/Linux to Power User Setup

### Step 1: Bootstrap (5 minutes)

```bash
# One command to rule them all
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)
```

This will:
- ✅ Install all essential tools
- ✅ Setup ZSH with Powerlevel10k
- ✅ Configure SSH infrastructure
- ✅ Create work/personal directories
- ✅ Setup direnv for auto-context switching

### Step 2: Configure Git (1 minute)

```bash
# Edit work config
nano ~/.gitconfig.work
```

Change:
```ini
[user]
    name = Your Work Name      # ← Update this
    email = work@company.com   # ← Update this
```

```bash
# Edit personal config
nano ~/.gitconfig.personal
```

Change:
```ini
[user]
    name = Your Personal Name      # ← Update this
    email = personal@email.com     # ← Update this
```

### Step 3: Add SSH Keys to GitHub/GitLab (2 minutes)

The bootstrap script created your keys. Now add them:

```bash
# Show work public key
cat ~/.ssh/keys/work/id_ed25519.pub

# Show personal public key
cat ~/.ssh/keys/personal/id_ed25519.pub
```

**Add to GitHub:**
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste the public key
4. Repeat for work and personal accounts

### Step 4: Test Everything (1 minute)

```bash
# Restart shell
exec zsh

# Test work context
cd ~/work
ssh-test

# Test personal context
cd ~/personal
ssh-test
```

## 🎯 Core Concept: How It Works

```
📁 Directory Structure:
~/
├── work/              → Automatically uses work SSH + Git config
│   └── .envrc        → Loads work credentials
├── personal/         → Automatically uses personal SSH + Git config
│   └── .envrc        → Loads personal credentials
└── .ssh/
    ├── config        → Main config with includes
    ├── config.work   → Work SSH hosts
    ├── config.personal → Personal SSH hosts
    └── keys/
        ├── work/id_ed25519     → Work SSH key
        └── personal/id_ed25519 → Personal SSH key
```

**Magic happens via `direnv`:**
- When you `cd ~/work` → work SSH key loads
- When you `cd ~/personal` → personal SSH key loads
- Git automatically uses the correct email/name

## 💡 Daily Workflow Examples

### Example 1: Work on Company Project

```bash
# Navigate to work
work  # shortcut for cd ~/work

# Status shows you're in work context
ssh-status

# Clone company repo (uses work credentials automatically)
git clone git@github.com-work:company/backend.git
cd backend

# Git commits use work email
git config user.email  # → work@company.com

# Make changes and push (uses work SSH key)
git add .
git commit -m "Add feature"
git push  # ← Uses work SSH key automatically!
```

### Example 2: Work on Personal Project

```bash
# Navigate to personal
personal  # shortcut for cd ~/personal

# Status shows you're in personal context
ssh-status

# Clone personal repo (uses personal credentials automatically)
git clone git@github.com-personal:username/my-app.git
cd my-app

# Git commits use personal email
git config user.email  # → personal@email.com

# Make changes and push (uses personal SSH key)
git add .
git commit -m "Update README"
git push  # ← Uses personal SSH key automatically!
```

### Example 3: Create New Project

```bash
# For work project
cd ~/work
new-project client-dashboard
# → Creates directory, initializes git with work config

# For personal project
cd ~/personal
new-project side-hustle
# → Creates directory, initializes git with personal config
```

## 🔍 Essential Commands

### Check Status
```bash
ssh-status                    # Show current context & loaded keys
envinfo                       # Show all environment info
git config user.email         # Check which email is active
```

### Context Management
```bash
work                          # Go to work directory
personal                      # Go to personal directory
ssh-test                      # Test SSH connections
```

### Cloning Repos
```bash
# Smart clone (uses current context)
gclone git@github.com:user/repo.git

# Or use the context manager
sshc clone git@github.com:user/repo.git
```

## 🐛 Quick Fixes

### "Permission denied (publickey)"

```bash
# Check which keys are loaded
ssh-add -l

# Manually load work key
ssh-add ~/.ssh/keys/work/id_ed25519

# Or reload direnv
direnv reload
```

### "direnv: error .envrc is blocked"

```bash
# Allow direnv in current directory
direnv allow .

# Or allow both directories at once
direnv allow ~/work
direnv allow ~/personal
```

### Wrong Git email is being used

```bash
# Check current directory
pwd  # Make sure you're in correct context

# Check Git config
git config user.email

# If wrong, you might be in the wrong directory
# Or direnv hasn't loaded yet
cd ~/work  # or ~/personal
direnv reload
```

### SSH key not found

```bash
# Check if keys exist
ls -la ~/.ssh/keys/work/
ls -la ~/.ssh/keys/personal/

# If missing, generate them
sshc add-key work
sshc add-key personal
```

## 📝 Customization Quick Tips

### Add More Contexts

```bash
# Create new context (e.g., "freelance")
mkdir -p ~/freelance ~/.ssh/keys/freelance

# Create .envrc
cat > ~/freelance/.envrc << 'EOF'
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/freelance/id_ed25519"
export SSH_AUTH_SOCK_CONTEXT="freelance"
EOF

# Generate key
ssh-keygen -t ed25519 -C "freelance@email.com" -f ~/.ssh/keys/freelance/id_ed25519

# Allow direnv
direnv allow ~/freelance

# Create configs
nano ~/.ssh/config.freelance
nano ~/.gitconfig.freelance
```

### Add Custom Aliases

```bash
# Edit zshrc
nano ~/.zshrc

# Add aliases
alias myalias='command here'

# Reload
reload
```

### Change Theme

```bash
# Reconfigure Powerlevel10k
p10k configure
```

## 🎓 Pro Tips

1. **Always `cd` to correct directory first** - The context loads based on directory
2. **Use `ssh-status` when unsure** - Quick way to see what's loaded
3. **Use `gclone` instead of `git clone`** - It's context-aware and cd's into repo
4. **Check `git config user.email`** before committing - Verify correct identity
5. **Use `new-project` to start projects** - Auto-configures everything correctly

## 📚 Learn More

- Full README: `cat ~/.dotfiles/README.md`
- SSH Context Manager help: `sshc help`
- Direnv docs: https://direnv.net/
- Git conditional includes: `man git-config`

## 🔄 Maintenance

### Update Everything

```bash
# Update dotfiles
cd ~/.dotfiles && git pull && ./install.sh

# Update Oh-My-Zsh
omz update

# Update Node.js
fnm install --lts && fnm use lts-latest

# Update system
sudo apt update && sudo apt upgrade -y

# Reload shell
exec zsh
```

### Backup SSH Keys

```bash
# Backup to external drive or cloud
tar -czf ssh-backup-$(date +%Y%m%d).tar.gz ~/.ssh/keys/

# Restore from backup
tar -xzf ssh-backup-*.tar.gz -C ~/
```

---

**💡 Remember:** The whole system is based on directories. Stay in `~/work` or `~/personal` and everything "just works"!