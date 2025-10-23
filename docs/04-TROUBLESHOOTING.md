← [Previous: FAQ](03-FAQ.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: WSL-Specific →](05-WSL-SPECIFIC.md)

---

# Troubleshooting Guide

## Table of Contents

1. [SSH Issues](#ssh-issues)
2. [Direnv Issues](#direnv-issues)
3. [Git Configuration Issues](#git-configuration-issues)
4. [Permission Issues](#permission-issues)
5. [Performance Issues](#performance-issues)
6. [WSL-Specific Issues](#wsl-specific-issues)
7. [FAQ](#frequently-asked-questions)

---

## SSH Issues

### ❌ Problem: "Permission denied (publickey)"

**Symptoms:**
```bash
git push
# Permission denied (publickey).
# fatal: Could not read from remote repository.
```

**Solutions:**

```bash
# 1. Check if you're using the correct host
git remote -v
# Should show: git@github.com-work:... or git@github.com-personal:...

# 2. Check if SSH key is loaded
ssh-add -l
# If empty, load your key:
ssh-add ~/.ssh/keys/work/id_ed25519

# 3. Test SSH connection
ssh -T git@github.com-work
# Should see: "Hi username! You've successfully authenticated..."

# 4. Check SSH config
cat ~/.ssh/config.work
# Verify IdentityFile path is correct

# 5. Verify key permissions
chmod 600 ~/.ssh/keys/work/id_ed25519
chmod 644 ~/.ssh/keys/work/id_ed25519.pub

# 6. Check if key is added to GitHub/GitLab
cat ~/.ssh/keys/work/id_ed25519.pub
# Copy and verify it's in your GitHub settings
```

### ❌ Problem: SSH agent not persisting between sessions

**Symptoms:**
```bash
# After restarting terminal
ssh-add -l
# Could not open a connection to your authentication agent
```

**Solutions:**

```bash
# Install and use keychain (recommended for WSL)
sudo apt install keychain

# Add to ~/.zshrc
eval $(keychain --eval --quiet --agents ssh ~/.ssh/keys/work/id_ed25519 ~/.ssh/keys/personal/id_ed25519)

# Reload shell
exec zsh
```

### ❌ Problem: Wrong SSH key being used

**Symptoms:**
```bash
# Commits showing wrong author
git log --oneline
# Shows personal email on work project (or vice versa)
```

**Solutions:**

```bash
# 1. Check current directory context
pwd
ssh-status

# 2. Verify you're in the correct directory
cd ~/work  # or ~/personal

# 3. Force reload direnv
direnv reload

# 4. Check which SSH keys are loaded
ssh-add -l

# 5. Manually set GIT_SSH_COMMAND for this session
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/work/id_ed25519 -F ~/.ssh/config.work"
```

---

## Direnv Issues

### ❌ Problem: direnv not loading automatically

**Symptoms:**
```bash
cd ~/work
# No "🏢 Switched to WORK environment" message
echo $SSH_AUTH_SOCK_CONTEXT
# Empty or "none"
```

**Solutions:**

```bash
# 1. Check if direnv is installed
command -v direnv

# 2. Check if hook is in shell config
grep "direnv hook" ~/.zshrc

# 3. If missing, add it:
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# 4. Allow direnv in directory
cd ~/work
direnv allow

cd ~/personal
direnv allow

# 5. Verify .envrc files exist
ls -la ~/work/.envrc
ls -la ~/personal/.envrc

# 6. Check direnv status
direnv status
```

### ❌ Problem: "direnv: error .envrc is blocked"

**Symptoms:**
```bash
cd ~/work
# direnv: error /home/user/work/.envrc is blocked. Run `direnv allow` to approve its content
```

**Solution:**

```bash
# Allow the .envrc file
direnv allow ~/work
direnv allow ~/personal

# Or allow in current directory
direnv allow .
```

### ❌ Problem: Changes to .envrc not taking effect

**Solutions:**

```bash
# 1. Reload direnv
direnv reload

# 2. Or manually source the file
cd ~/work
source .envrc

# 3. Check for syntax errors in .envrc
bash -n ~/work/.envrc

# 4. Re-allow after changes
direnv allow ~/work
```

---

## Git Configuration Issues

### ❌ Problem: Wrong email/name in commits

**Symptoms:**
```bash
git log
# Shows personal email in work commits (or vice versa)
```

**Solutions:**

```bash
# 1. Check current Git config
git config user.name
git config user.email

# 2. Check where config is coming from
git config --show-origin user.email

# 3. Verify you're in correct directory
pwd  # Should be under ~/work or ~/personal

# 4. Check Git conditional includes
cat ~/.gitconfig | grep includeIf

# 5. Manually check if context config exists
cat ~/.gitconfig.work
cat ~/.gitconfig.personal

# 6. Fix past commits (if needed)
git config user.email "correct@email.com"
git commit --amend --reset-author --no-edit
```

### ❌ Problem: Git conditional includes not working

**Solutions:**

```bash
# 1. Verify directory path in .gitconfig
cat ~/.gitconfig

# Should have:
# [includeIf "gitdir:~/work/"]
#     path = ~/.gitconfig.work

# 2. Check Git version (needs 2.13+)
git --version

# 3. Test conditional include
cd ~/work
git config --list --show-origin | grep user

# 4. Ensure trailing slash in gitdir path
# Correct:   gitdir:~/work/
# Incorrect: gitdir:~/work

# 5. Use full path if relative doesn't work
[includeIf "gitdir:/home/username/work/"]
    path = ~/.gitconfig.work
```

---

## Permission Issues

### ❌ Problem: "Permission denied" on SSH keys

**Symptoms:**
```bash
ssh-add ~/.ssh/keys/work/id_ed25519
# Error loading key: bad permissions
```

**Solution:**

```bash
# Fix SSH directory permissions
chmod 700 ~/.ssh
chmod 700 ~/.ssh/keys
chmod 700 ~/.ssh/keys/work
chmod 700 ~/.ssh/keys/personal

# Fix key permissions
chmod 600 ~/.ssh/keys/work/id_ed25519
chmod 644 ~/.ssh/keys/work/id_ed25519.pub
chmod 600 ~/.ssh/keys/personal/id_ed25519
chmod 644 ~/.ssh/keys/personal/id_ed25519.pub

# Fix config permissions
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/config.work
chmod 600 ~/.ssh/config.personal
```

### ❌ Problem: "bad ownership or modes" on .envrc

**Solution:**

```bash
# Fix .envrc permissions
chmod 600 ~/work/.envrc
chmod 600 ~/personal/.envrc

# Re-allow
direnv allow ~/work
direnv allow ~/personal
```

---

## Performance Issues

### ❌ Problem: Slow Git operations in WSL

**Solutions:**

```bash
# 1. Ensure you're working in WSL filesystem, not /mnt/c/
pwd
# Should start with /home/..., NOT /mnt/c/...

# 2. If you must use /mnt/c/, disable Git file mode
git config --global core.fileMode false

# 3. Move project to WSL filesystem
cp -r /mnt/c/Projects/myproject ~/work/
cd ~/work/myproject

# 4. Exclude WSL from Windows Defender (PowerShell as Admin)
Add-MpPreference -ExclusionPath "\\wsl$\Ubuntu\home"
```

### ❌ Problem: Shell startup is slow

**Solutions:**

```bash
# 1. Profile zsh startup
time zsh -i -c exit

# 2. Disable plugins temporarily to identify culprit
# Edit ~/.zshrc and comment out plugins one by one

# 3. Use lazy loading for heavy tools
# Instead of: eval "$(pyenv init -)"
# Use: alias pyenv='eval "$(pyenv init -)" && pyenv'

# 4. Clear zsh compilation cache
rm -f ~/.zcompdump*
rm -rf ~/.zsh/cache

# 5. Recompile zsh config
zsh -fc 'autoload -U compinit; compinit'
```

---

## WSL-Specific Issues

### ❌ Problem: Can't connect to Docker from WSL

**Solutions:**

```bash
# 1. Ensure Docker Desktop is running on Windows

# 2. Enable WSL integration in Docker Desktop settings
# Settings > Resources > WSL Integration > Enable Ubuntu

# 3. Check Docker socket
ls -la /var/run/docker.sock

# 4. Test Docker connection
docker ps

# 5. If still not working, restart WSL
# From PowerShell:
wsl --shutdown
```

### ❌ Problem: DNS not working in WSL

**Solutions:**

```bash
# 1. Create/edit /etc/wsl.conf
sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[network]
generateResolvConf = false
EOF

# 2. Create resolv.conf
sudo tee /etc/resolv.conf > /dev/null << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# 3. Make it immutable
sudo chattr +i /etc/resolv.conf

# 4. Restart WSL (from PowerShell)
wsl --shutdown
```

### ❌ Problem: WSL running out of memory

**Solutions:**

```bash
# 1. Create C:\Users\YOUR_USERNAME\.wslconfig
[wsl2]
memory=8GB
processors=4
swap=2GB

# 2. Restart WSL (from PowerShell)
wsl --shutdown

# 3. Clear page cache (from WSL)
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
```

---

## Frequently Asked Questions

### Q: How do I add a third context (e.g., "freelance")?

**A:**
```bash
# 1. Create directory and key
mkdir -p ~/freelance ~/.ssh/keys/freelance
ssh-keygen -t ed25519 -f ~/.ssh/keys/freelance/id_ed25519

# 2. Create .envrc
cat > ~/freelance/.envrc << 'EOF'
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/freelance/id_ed25519"
export SSH_AUTH_SOCK_CONTEXT="freelance"
ssh-add ~/.ssh/keys/freelance/id_ed25519 2>/dev/null || true
echo "💼 Switched to FREELANCE environment"
EOF

# 3. Create configs
echo -e "\nHost github.com-freelance\n    HostName github.com\n    User git\n    IdentityFile ~/.ssh/keys/freelance/id_ed25519" > ~/.ssh/config.freelance

cat > ~/.gitconfig.freelance << 'EOF'
[user]
    name = Freelance Name
    email = freelance@email.com
[core]
    sshCommand = ssh -i ~/.ssh/keys/freelance/id_ed25519
EOF

# 4. Update main configs
echo 'Include config.freelance' >> ~/.ssh/config
echo -e '\n[includeIf "gitdir:~/freelance/"]\n    path = ~/.gitconfig.freelance' >> ~/.gitconfig

# 5. Allow direnv
direnv allow ~/freelance
```

### Q: Can I use this with GitLab, Bitbucket, or other Git hosts?

**A:** Yes! Just add the appropriate host configurations:

```bash
# In ~/.ssh/config.work, add:
Host gitlab.com-work
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/keys/work/id_ed25519

Host bitbucket.org-work
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/keys/work/id_ed25519

# Then clone with:
git clone git@gitlab.com-work:company/repo.git
git clone git@bitbucket.org-work:company/repo.git
```

### Q: How do I migrate existing projects to this setup?

**A:**
```bash
# 1. Move project to correct context directory
mv ~/old-location/my-work-project ~/work/

# 2. Update Git remote URL
cd ~/work/my-work-project
git remote set-url origin git@github.com-work:company/repo.git

# 3. Verify configuration
cd ~/work/my-work-project
git config user.email  # Should show work email
ssh-status  # Should show work context

# 4. Test connection
git fetch
```

### Q: How do I backup my SSH keys?

**A:**
```bash
# Backup to encrypted archive
tar -czf - ~/.ssh/keys | gpg --symmetric --cipher-algo AES256 > ssh-keys-backup.tar.gz.gpg

# Restore from backup
gpg --decrypt ssh-keys-backup.tar.gz.gpg | tar -xzf - -C ~/

# Or simpler (no encryption)
tar -czf ~/Dropbox/ssh-keys-$(date +%Y%m%d).tar.gz ~/.ssh/keys
```

### Q: Can I use this setup with multiple GitHub accounts?

**A:** Yes, that's exactly what this setup is for! Each context can use a different GitHub account.

```bash
# Work account: github.com-work
# Personal account: github.com-personal

# Just make sure each SSH key is added to the respective GitHub account
```

### Q: How do I completely reset and start fresh?

**A:**
```bash
# Backup first!
tar -czf ~/dotfiles-backup.tar.gz ~/.dotfiles ~/.ssh ~/.gitconfig*

# Remove everything
rm -rf ~/.dotfiles
rm -rf ~/.ssh/keys
rm ~/.ssh/config*
rm ~/.gitconfig*
rm ~/work/.envrc
rm ~/personal/.envrc

# Re-run bootstrap
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)
```

### Q: How do I check which SSH key is currently being used?

**A:**
```bash
# Method 1: Use ssh-status
ssh-status

# Method 2: Check loaded keys
ssh-add -l

# Method 3: Check environment variable
echo $GIT_SSH_COMMAND

# Method 4: Verbose SSH connection
ssh -vT git@github.com-work 2>&1 | grep "identity file"
```

### Q: Can I use password-protected SSH keys?

**A:** Yes, but you'll need to enter the password each time unless you use keychain or ssh-agent:

```bash
# Generate key with passphrase
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/keys/work/id_ed25519

# Use keychain to remember passphrase (recommended)
eval $(keychain --eval --quiet --agents ssh ~/.ssh/keys/work/id_ed25519)
```

### Q: How do I update my dotfiles repository?

**A:**
```bash
cd ~/.dotfiles
git pull
./install.sh
exec zsh
```

---

## Getting Help

If you're still experiencing issues:

1. **Check your setup:**
   ```bash
   ssh-status
   envinfo
   test-ssh-context
   ```

2. **Enable verbose logging:**
   ```bash
   # For SSH
   ssh -vvv git@github.com-work
   
   # For direnv
   export DIRENV_LOG_FORMAT=verbose
   ```

3. **Create an issue in your dotfiles repository with:**
   - Output of `ssh-status`
   - Output of `envinfo`
   - Error messages you're seeing
   - Steps to reproduce

---

**💡 Pro Tip:** Bookmark this file and refer to it whenever something doesn't work as expected!