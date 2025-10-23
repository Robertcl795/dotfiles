# 🚀 Context-Aware Dotfiles

**Automated development environment with intelligent SSH and Git context management**

> Transform any fresh Linux/WSL system into a fully configured development environment in under 10 minutes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-WSL%20%7C%20Ubuntu%20%7C%20Debian-blue)]()

---

## ✨ What is This?

This dotfiles system **automatically manages SSH keys and Git configurations** based on which directory you're in. No more manual switching, no more wrong credentials in commits.

**The Magic:**
```bash
cd ~/work      # 🏢 Automatically uses work SSH key + work Git config
cd ~/personal  # 🏠 Automatically uses personal SSH key + personal Git config
```

### Key Features

- 🔐 **Context-Aware SSH** - Automatic SSH key switching per directory
- 🎯 **Smart Git Config** - Correct name/email based on project location
- ⚡ **One-Command Install** - Fresh system to fully configured in ~10 min
- 🎨 **Modern Terminal** - Powerlevel10k + modern CLI tools (eza, bat, fzf, ripgrep)
- 🛠️ **Dev Tools Included** - Docker, direnv, jq, and essential utilities
- 📚 **Well Documented** - Comprehensive guides for every scenario
- ✅ **Production Ready** - Tested on WSL, Ubuntu 20.04, 22.04, 24.04

---

## 🚀 Quick Start

### Installation (Choose One Method)

#### Option 1: Quick Setup (Recommended for First Time)

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./quick-setup.sh
```

#### Option 2: Bootstrap (One Command)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh)
```

#### Option 3: Manual (Full Control)

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install    # or: ./install.sh
make configure  # or: ./configure.sh
```

### Post-Installation

After installation, configure your credentials:

```bash
# Edit Git configs with your information
nano ~/.gitconfig.work      # Add work name & email
nano ~/.gitconfig.personal  # Add personal name & email

# Add SSH keys to GitHub
cat ~/.ssh/keys/work/id_ed25519.pub      # Copy and add to GitHub
cat ~/.ssh/keys/personal/id_ed25519.pub  # Copy and add to GitHub

# Test it works
cd ~/work && ssh-status      # Should show: 🏢 WORK
cd ~/personal && ssh-status  # Should show: 🏠 PERSONAL
```

**📖 Full Guide**: See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for detailed step-by-step instructions.

## � Documentation

Complete documentation is organized in the [`docs/`](docs/) directory:

- **[📑 Documentation Index](docs/00-INDEX.md)** - Start here for guided navigation
- **[🚀 Quick Start](docs/01-QUICKSTART.md)** - Get up and running in 5 minutes
- **[💡 Examples](docs/02-EXAMPLES.md)** - Real-world usage scenarios
- **[❓ FAQ](docs/03-FAQ.md)** - Frequently asked questions
- **[🔧 Troubleshooting](docs/04-TROUBLESHOOTING.md)** - Common issues and solutions
- **[🐧 WSL-Specific Guide](docs/05-WSL-SPECIFIC.md)** - Windows Subsystem for Linux setup
- **[📁 Structure Details](docs/06-STRUCTURE.md)** - Comprehensive file organization
- **[📝 Project Summary](docs/07-SUMMARY.md)** - High-level overview
- **[🤝 Contributing](docs/08-CONTRIBUTING.md)** - How to contribute
- **[📜 Changelog](docs/09-CHANGELOG.md)** - Version history

### Quick Navigation

| I want to...                          | Go to                                                      |
|---------------------------------------|------------------------------------------------------------|
| Install and configure everything      | [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)        |
| Quick 5-minute setup                  | [Quick Start](docs/01-QUICKSTART.md)                     |
| See real examples                     | [Examples](docs/02-EXAMPLES.md)                           |
| Fix an issue                          | [Troubleshooting](docs/04-TROUBLESHOOTING.md)            |
| Set up on WSL                         | [WSL Guide](docs/05-WSL-SPECIFIC.md)                     |
| Browse all docs                       | [Documentation Index](docs/00-INDEX.md)                   |

## �📁 Directory Structure

```text
~/.dotfiles/
├── bootstrap.sh              # Main bootstrap script
├── install.sh                # Dotfiles installation
├── config/                   # Configuration files
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .gitconfig.work
│   ├── .gitconfig.personal
│   └── .npmrc
├── bin/                      # Custom scripts
│   ├── ssh-context-manager
│   └── test-ssh-context
└── scripts/
    └── setup/
        ├── setup-zsh.sh
        └── install-dev-tools.sh
```

## 🔐 SSH Context Management

### How It Works

The setup automatically configures **context-aware SSH credentials**:

- **`~/work/`** - Uses work SSH keys and Git configuration
- **`~/personal/`** - Uses personal SSH keys and Git configuration

### Directory Structure

```text
~/.ssh/
├── config                    # Main SSH config
├── config.work              # Work-specific config
├── config.personal          # Personal-specific config
└── keys/
    ├── work/
    │   ├── id_ed25519
    │   └── id_ed25519.pub
    └── personal/
        ├── id_ed25519
        └── id_ed25519.pub
```

### Usage

```bash
# Navigate to work directory
cd ~/work

# direnv automatically loads work SSH key and Git config
# Clone with work credentials
git clone git@github.com-work:company/repo.git

# Navigate to personal directory
cd ~/personal

# direnv automatically switches to personal SSH key and Git config
# Clone with personal credentials
git clone git@github.com-personal:username/repo.git
```

### SSH Context Manager Commands

```bash
# Check current SSH context
ssh-status

# Test SSH connections
ssh-test

# List all available contexts
ssh-list

# Show current configuration
ssh-config

# Smart clone (automatically uses correct context)
sshc clone git@github.com:user/repo.git

# Add new SSH key
sshc add-key work
```

## 🛠️ What Gets Installed

### Shell & Terminal

- ZSH with Oh-My-Zsh
- Powerlevel10k theme
- Modern CLI tools: eza, bat, ripgrep, fd, zoxide, delta

### Development Tools

- **Node.js** - via FNM (Fast Node Manager)
- **Python** - via Pyenv
- **Go** - Latest stable version
- **Rust** - via rustup

### Container & Cloud

- Docker & Docker Compose
- K3D (Kubernetes in Docker)
- kubectl & Helm
- Terraform
- Ansible
- AWS CLI

### Version Control & Utilities

- Git with delta (better diffs)
- GitHub CLI (gh)
- FZF (fuzzy finder)
- Direnv (directory-based environment management)

## ⚙️ Configuration

### Git Configuration

The setup creates three Git configurations:

1. **`~/.gitconfig`** - Main config with conditional includes
2. **`~/.gitconfig.work`** - Work-specific user and SSH settings
3. **`~/.gitconfig.personal`** - Personal user and SSH settings

Edit these files to set your name and email:

```bash
# Edit work config
nano ~/.gitconfig.work

# Edit personal config
nano ~/.gitconfig.personal
```

### SSH Configuration

SSH configs are automatically created with sensible defaults. You can customize them:

```bash
# Edit work SSH config
nano ~/.ssh/config.work

# Edit personal SSH config
nano ~/.ssh/config.personal
```

### Environment Variables

Direnv automatically loads environment variables based on directory. Edit `.envrc` files:

```bash
# Edit work environment
nano ~/work/.envrc

# Edit personal environment
nano ~/personal/.envrc
```

## 📚 Common Workflows

### Starting a New Work Project

```bash
# Navigate to work directory
work  # alias for 'cd ~/work'

# Create new project
new-project my-app

# Initialize with your preferred stack
npm init -y
# or
cargo init
# or
go mod init company.com/my-app
```

### Cloning Repositories

```bash
# Work repository
cd ~/work
gclone git@github.com:company/repo.git

# Personal repository
cd ~/personal
gclone git@github.com:username/repo.git
```

### Switching Contexts

```bash
# Go to work (automatically loads work context)
go-work

# Go to personal (automatically loads personal context)
go-personal

# Check current context
ssh-status
```

## 🎨 Customization

### Adding Custom Aliases

Edit `~/.zshrc` and add your aliases:

```bash
# Edit ZSH configuration
nano ~/.dotfiles/config/.zshrc

# Reload configuration
reload  # alias for 'source ~/.zshrc'
```

### Adding New SSH Contexts

You can add additional contexts beyond work/personal:

```bash
# Create new context directory
mkdir -p ~/freelance

# Create .envrc file
cat > ~/freelance/.envrc << 'EOF'
export GIT_SSH_COMMAND="ssh -i ~/.ssh/keys/freelance/id_ed25519"
export SSH_AUTH_SOCK_CONTEXT="freelance"
EOF

# Allow direnv
direnv allow ~/freelance

# Generate SSH key
sshc add-key freelance

# Create SSH config
nano ~/.ssh/config.freelance

# Create Git config
nano ~/.gitconfig.freelance
```

## 🔧 Troubleshooting

### SSH Key Not Loading

```bash
# Check if SSH agent is running
ssh-add -l

# Manually add key
ssh-add ~/.ssh/keys/work/id_ed25519

# Check direnv status
direnv status
```

### Direnv Not Working

```bash
# Allow direnv in current directory
direnv allow .

# Check if direnv hook is in shell
echo $SHELL
grep direnv ~/.zshrc
```

### Git Using Wrong Credentials

```bash
# Check current Git configuration
git config user.name
git config user.email

# Verify you're in the correct directory
pwd

# Check SSH context
ssh-status

# Test SSH connection
ssh -T git@github.com-work
ssh -T git@github.com-personal
```

### Fresh Install Issues

```bash
# Ensure all scripts are executable
chmod +x ~/.dotfiles/bootstrap.sh
chmod +x ~/.dotfiles/install.sh
chmod +x ~/.dotfiles/scripts/setup/*.sh

# Run bootstrap again
~/.dotfiles/bootstrap.sh

# Check logs
journalctl --user -xe
```

## 📋 Useful Commands Reference

### Navigation

```bash
work          # Go to ~/work
personal      # Go to ~/personal
dev           # Go to ~/dev
..            # Go up one directory
...           # Go up two directories
```

### Git

```bash
gs            # git status
ga            # git add
gc            # git commit
gp            # git push
gl            # git pull
gco           # git checkout
glog          # pretty git log
```

### Docker

```bash
d             # docker
dc            # docker-compose
dps           # docker ps
dimg          # docker images
dex           # docker exec -it
docker-cleanup # Clean up Docker resources
```

### Kubernetes

```bash
k             # kubectl
kgp           # kubectl get pods
kgs           # kubectl get services
k3d-start     # Start/create K3D cluster
k3d-stop      # Stop K3D cluster
```

### SSH

```bash
ssh-status    # Show current SSH context
ssh-test      # Test SSH connections
ssh-list      # List all SSH contexts
sshc          # ssh-context-manager shorthand
```

### Utilities

```bash
envinfo       # Show environment information
search <term> # Search in project (ripgrep)
findfile <name> # Find files by name
extract <file> # Extract any archive
killport <port> # Kill process on port
```

## 🔄 Updating

### Update Dotfiles

```bash
cd ~/.dotfiles
git pull
./install.sh
reload
```

### Update Tools

```bash
# Update Oh-My-Zsh
omz update

# Update FNM and Node
fnm install --lts
fnm use lts-latest

# Update Rust
rustup update

# Update system packages
sudo apt update && sudo apt upgrade -y
```

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs!

## 📝 License

MIT License - Feel free to use this configuration for your own setup.

## 🙏 Credits

Built with:

- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Direnv](https://direnv.net/)
- [FNM](https://github.com/Schniz/fnm)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)

---

## **Made with ❤️ for developers who value automation and clean workflows**
