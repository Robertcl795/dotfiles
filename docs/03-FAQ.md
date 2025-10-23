← [Previous: Examples](02-EXAMPLES.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: Troubleshooting →](04-TROUBLESHOOTING.md)

---

# FAQ - Frequently Asked Questions

## 🤔 General Questions

### Q: What is this dotfiles repository for?

**A:** This dotfiles repository provides a complete, automated development environment setup with intelligent SSH and Git context management. It allows you to seamlessly work on multiple projects (work and personal) without manually switching credentials or configurations.

### Q: Do I need to be an expert to use this?

**A:** No! The bootstrap script handles everything automatically. If you can run one command in a terminal, you can use this system.

### Q: What operating systems are supported?

**A:** Currently tested and optimized for:
- WSL (Windows Subsystem for Linux)
- Ubuntu/Debian-based Linux distributions
- Other Linux distributions (with minor modifications)

macOS support is planned for future releases.

### Q: Will this overwrite my existing configuration?

**A:** The installation script creates backups of all existing configuration files before making changes. You can restore them using the uninstall script.

## 🔧 Installation Questions

### Q: What is installed by the bootstrap script?

**A:** The bootstrap script installs:
- ZSH shell with Oh-My-Zsh
- Powerlevel10k theme
- Modern CLI tools (eza, bat, ripgrep, fzf, etc.)
- Git and essential development tools
- direnv for automatic context switching
- SSH infrastructure
- All dotfiles configurations

### Q: How long does the bootstrap process take?

**A:** Typically 5-10 minutes, depending on your internet connection and system performance.

### Q: Can I run the bootstrap script multiple times?

**A:** Yes! The script is idempotent - it checks what's already installed and only installs missing components.

### Q: What if the bootstrap script fails midway?

**A:** The script is designed to be re-runnable. Simply run it again, and it will continue from where it left off.

## 🔑 SSH and Git Questions

### Q: How does the automatic context switching work?

**A:** When you navigate to `~/work` or `~/personal`, direnv automatically:
1. Loads the appropriate SSH key
2. Sets Git configuration variables
3. Updates environment variables

All this happens transparently in the background.

### Q: Do I need separate GitHub accounts for work and personal?

**A:** No! You can use the same GitHub account with different SSH keys. The system uses SSH host aliases (like `github.com-work` and `github.com-personal`) to differentiate.

### Q: How do I add SSH keys to GitHub?

**A:** After running the bootstrap script:

1. Display your work public key:
   ```bash
   cat ~/.ssh/keys/work/id_ed25519.pub
   ```

2. Copy the output and add it to GitHub:
   - Go to GitHub → Settings → SSH and GPG keys → New SSH key
   - Paste the public key

3. Repeat for personal key:
   ```bash
   cat ~/.ssh/keys/personal/id_ed25519.pub
   ```

### Q: Can I use this with GitLab or Bitbucket?

**A:** Yes! The SSH configuration templates include examples for GitLab and Bitbucket. Just uncomment and configure them in `~/.ssh/config.work` and `~/.ssh/config.personal`.

### Q: What if I already have SSH keys?

**A:** The bootstrap script will ask if you want to use existing keys or generate new ones. You can safely keep your existing keys.

### Q: How do I add more contexts (e.g., freelance, open-source)?

**A:** You can add more contexts by:

1. Creating a new directory: `mkdir ~/freelance`
2. Creating SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/keys/freelance/id_ed25519`
3. Creating SSH config: `~/.ssh/config.freelance`
4. Creating Git config: `~/.gitconfig.freelance`
5. Creating `.envrc` in `~/freelance` directory
6. Adding includeIf to main `.gitconfig`

## 🐛 Troubleshooting

### Q: Context isn't switching automatically

**A:** Check the following:

1. Verify direnv is installed: `which direnv`
2. Check if direnv is hooked in `.zshrc`: `grep direnv ~/.zshrc`
3. Verify `.envrc` files exist: `ls ~/work/.envrc ~/personal/.envrc`
4. Allow direnv: `cd ~/work && direnv allow`
5. Restart your shell or run: `source ~/.zshrc`

### Q: Git is using the wrong email address

**A:** Check Git configuration:

```bash
# See which config is being used
git config --list --show-origin | grep user.email

# Verify you're in the right directory
pwd

# Check if includeIf is working
git config user.email
```

If the email is wrong, verify the `includeIf` sections in `~/.gitconfig`.

### Q: SSH key is not loaded

**A:** Verify SSH key loading:

```bash
# Check loaded keys
ssh-add -l

# Check environment variable
echo $SSH_AUTH_SOCK_CONTEXT

# Manually load work key
ssh-add ~/.ssh/keys/work/id_ed25519

# Check direnv status
cd ~/work
direnv status
```

### Q: Permission denied (publickey) when pushing to GitHub

**A:** This usually means:

1. SSH key not added to GitHub - Add your public key to GitHub
2. Wrong SSH URL - Use `git@github.com-work:` or `git@github.com-personal:`
3. SSH agent not running - Run `eval $(ssh-agent)` and try again
4. Wrong key loaded - Run `ssh-status` to verify

Test SSH connection:
```bash
ssh -T git@github.com-work
ssh -T git@github.com-personal
```

### Q: Commands not found after installation

**A:** Some issues to check:

1. Restart your terminal or run: `source ~/.zshrc`
2. Check if tools are in PATH: `echo $PATH`
3. For custom scripts, ensure `~/.local/bin` is in PATH
4. Re-run installation: `cd ~/.dotfiles && ./install.sh`

### Q: Powerlevel10k theme not showing correctly

**A:** This is usually a font issue:

1. Install a Nerd Font (MesloLGS NF recommended)
2. Configure your terminal to use the Nerd Font
3. Run `p10k configure` to reconfigure the theme
4. For WSL, configure Windows Terminal to use the Nerd Font

## 🔄 Updates and Maintenance

### Q: How do I update the dotfiles?

**A:** Run the update script:

```bash
cd ~/.dotfiles
./update.sh
# Or use make
make update
```

This will:
- Pull latest changes from the repository
- Update Oh-My-Zsh and plugins
- Re-install dotfiles
- Update dependencies

### Q: How do I customize the configuration?

**A:** You can customize in several ways:

1. **Local overrides**: Create `~/.zshrc.local` for personal customizations
2. **Edit directly**: Modify files in `~/.dotfiles/config/`
3. **Add aliases**: Edit `~/.zsh_aliases`
4. **Add functions**: Edit `~/.zsh_functions`

Remember to commit your changes if you want to keep them in version control.

### Q: How do I back up my configuration?

**A:** Use the backup command:

```bash
make backup
# Or manually
cp -r ~/.dotfiles ~/dotfiles-backup-$(date +%Y%m%d)
```

### Q: How do I uninstall everything?

**A:** Run the uninstall script:

```bash
cd ~/.dotfiles
./uninstall.sh
# Or use make
make uninstall
```

This will remove symlinks and restore backups if available.

## 🚀 Usage Questions

### Q: What's the difference between `git clone` and `gclone`?

**A:** `gclone` is a smart wrapper that:
- Automatically uses the correct SSH host alias based on current context
- Changes to the repository directory after cloning
- Shows context information

Regular `git clone` requires you to manually specify the SSH host alias.

### Q: How do I know which context I'm in?

**A:** Several ways:

1. Check the terminal prompt (if using Powerlevel10k)
2. Run `ssh-status`
3. Check environment variable: `echo $SSH_AUTH_SOCK_CONTEXT`
4. Run `git-whoami` to see Git configuration

### Q: Can I use this for more than two contexts?

**A:** Yes! The system is designed to be extensible. You can add as many contexts as needed (work, personal, freelance, open-source, etc.).

### Q: What if I work on both work and personal projects in the same session?

**A:** No problem! The context automatically switches based on the directory you're in. You can have multiple terminal tabs/windows, each in a different context.

### Q: Do I need to manually switch SSH keys?

**A:** No! When you navigate to a directory with a `.envrc` file, direnv automatically loads the appropriate SSH key and Git configuration.

## 💻 Advanced Questions

### Q: Can I use this in a Docker container?

**A:** Yes! You can mount your dotfiles in a container or include them in your Dockerfile. However, some features (like direnv) may require additional setup.

### Q: How do I integrate this with VS Code?

**A:** VS Code will automatically use your Git configuration. For SSH, ensure VS Code's integrated terminal uses ZSH. You may need to install the "Remote - SSH" extension for remote development.

### Q: Can I use this with tmux?

**A:** Yes! The dotfiles are compatible with tmux. You may want to add tmux-specific configurations to your `.zshrc` or create a `.tmux.conf`.

### Q: How do I add new tools or configurations?

**A:** 

1. Add tool installation to `scripts/setup/install-dev-tools.sh`
2. Add configuration to `config/` directory
3. Update `install.sh` to symlink new configs
4. Update documentation

Consider contributing back via a pull request!

### Q: Can I use different shells (bash, fish)?

**A:** The system is designed for ZSH, but the core concepts (SSH contexts, Git configs) work with any shell. You'd need to adapt the shell-specific parts (`.zshrc`, aliases, functions) to your preferred shell.

## 📚 Learning Resources

### Q: I'm new to Git. Where can I learn more?

**A:** Resources:
- [Git Official Documentation](https://git-scm.com/doc)
- [GitHub Git Guides](https://github.com/git-guides)
- [Learn Git Branching](https://learngitbranching.js.org/)

### Q: I want to learn more about SSH. Where should I start?

**A:** Resources:
- [SSH Academy](https://www.ssh.com/academy/ssh)
- [GitHub SSH Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- `man ssh` - SSH manual page

### Q: Where can I learn about ZSH and Oh-My-Zsh?

**A:** Resources:
- [Oh-My-Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [ZSH Guide](https://zsh.sourceforge.io/Guide/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

## 🆘 Still Need Help?

If your question isn't answered here:

1. Check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide
2. Search [existing issues](https://github.com/YOUR_USERNAME/dotfiles/issues)
3. Create a new issue with:
   - Clear description of your problem
   - Steps to reproduce
   - System information
   - Relevant logs or error messages

---

**Didn't find your question?** Feel free to [open an issue](https://github.com/YOUR_USERNAME/dotfiles/issues/new) and ask! Your question might help others too. 🎉
