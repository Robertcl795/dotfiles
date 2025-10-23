← [Previous: WSL-Specific](05-WSL-SPECIFIC.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: Summary →](07-SUMMARY.md)

---

# Project Structure Documentation

```
dotfiles/
├── 📄 Core Scripts
│   ├── bootstrap.sh              # One-command installation from fresh system
│   ├── install.sh                # Dotfiles installer with SSH infrastructure
│   ├── update.sh                 # Update dotfiles and dependencies
│   ├── uninstall.sh              # Remove dotfiles and restore backups
│   └── test.sh                   # Test suite for verification
│
├── 📂 config/                    # Configuration files
│   ├── .gitconfig                # Main Git configuration
│   ├── .gitconfig.work           # Work-specific Git config
│   ├── .gitconfig.personal       # Personal Git config
│   ├── .gitignore_global         # Global gitignore patterns
│   ├── .zshrc                    # ZSH configuration with context awareness
│   ├── .zsh_aliases              # Custom ZSH aliases
│   └── .zsh_functions            # Custom ZSH functions
│
├── 📂 bin/                       # Custom executable scripts
│   └── ssh-context-manager.sh   # Advanced SSH context management CLI
│
├── 📂 scripts/                   # Installation and setup scripts
│   └── setup/
│       ├── setup-zsh.sh          # ZSH and Oh-My-Zsh installer
│       └── install-dev-tools.sh  # Modern development tools installer
│
├── 📂 templates/                 # Configuration templates
│   ├── .envrc.work               # direnv config for work context
│   ├── .envrc.personal           # direnv config for personal context
│   ├── ssh-config.main           # Main SSH configuration
│   ├── ssh-config.work           # Work SSH configuration
│   └── ssh-config.personal       # Personal SSH configuration
│
├── 📚 Documentation
│   ├── README.md                 # Main documentation and overview
│   ├── QUICKSTART.md             # Quick reference guide
│   ├── IMPLEMENTATION.md         # Step-by-step implementation guide
│   ├── EXAMPLES.md               # Practical usage examples
│   ├── FAQ.md                    # Frequently asked questions
│   ├── TROUBLESHOOTING.md        # Common issues and solutions
│   ├── WSL-SPECIFIC.md           # WSL optimizations and tips
│   ├── CONTRIBUTING.md           # Contribution guidelines
│   └── CHANGELOG.md              # Version history
│
├── 🛠️ Project Files
│   ├── Makefile                  # Convenient make commands
│   ├── LICENSE                   # MIT License
│   └── .gitignore                # Git ignore patterns
│
└── 📂 Runtime Directories (created during installation)
    ├── backup/                   # Backups of overwritten files
    │
    ├── ~/.ssh/                   # SSH infrastructure
    │   ├── config                # Main SSH config
    │   ├── config.work           # Work SSH hosts
    │   ├── config.personal       # Personal SSH hosts
    │   └── keys/
    │       ├── work/
    │       │   ├── id_ed25519
    │       │   └── id_ed25519.pub
    │       └── personal/
    │           ├── id_ed25519
    │           └── id_ed25519.pub
    │
    ├── ~/work/                   # Work projects directory
    │   ├── .envrc                # Auto-loads work context
    │   └── [your projects]/
    │
    └── ~/personal/               # Personal projects directory
        ├── .envrc                # Auto-loads personal context
        └── [your projects]/
```

## 🎯 Key Components

### Bootstrap & Installation

- **bootstrap.sh**: The entry point - run this on a fresh system
- **install.sh**: Installs and symlinks all configuration files
- **update.sh**: Updates everything (dotfiles, Oh-My-Zsh, plugins)
- **uninstall.sh**: Cleanly removes all installations

### Configuration Management

- **config/**: Contains all dotfiles that get symlinked to `~/`
- **templates/**: Template files used during installation
- **bin/**: Custom scripts added to PATH

### Context System

The magic happens through these components:

1. **direnv** + **.envrc files**: Automatically load context when entering directories
2. **SSH configs**: Separate configurations for each context
3. **Git configs**: Conditional includes based on directory
4. **ssh-context-manager**: CLI tool for managing contexts

### Documentation

Complete documentation covering:
- Setup and installation
- Daily usage patterns
- Troubleshooting guides
- Real-world examples
- FAQ

## 📊 File Count Summary

```
Total Files: 30+
├── Scripts: 8
├── Config Files: 11
├── Documentation: 9
├── Templates: 5
└── Project Files: 3
```

## 🔄 Installation Flow

```
1. bootstrap.sh
   ├── Installs system packages
   ├── Runs scripts/setup/setup-zsh.sh
   ├── Runs scripts/setup/install-dev-tools.sh
   ├── Creates directory structure
   ├── Generates SSH keys
   ├── Copies templates to appropriate locations
   └── Runs install.sh
       ├── Creates symlinks from config/ to ~/
       ├── Copies bin/ scripts to ~/.local/bin
       └── Sets up SSH and Git configurations
```

## 🎨 Visual Flow

```
Fresh System
     ↓
[bootstrap.sh]
     ↓
Install Tools & ZSH
     ↓
Create Directories
     ↓
Generate SSH Keys
     ↓
[install.sh]
     ↓
Symlink Configs
     ↓
Setup Context System
     ↓
✨ Ready to Use!
```

## 💡 Usage Pattern

```
User navigates: cd ~/work
     ↓
direnv detects .envrc
     ↓
Loads work SSH key
     ↓
Sets work Git config
     ↓
Exports environment variables
     ↓
🏢 Work context active!

User navigates: cd ~/personal
     ↓
direnv detects .envrc
     ↓
Loads personal SSH key
     ↓
Sets personal Git config
     ↓
Exports environment variables
     ↓
🏠 Personal context active!
```

---

**Note**: This structure is designed to be:
- ✅ Modular and extensible
- ✅ Easy to maintain
- ✅ Self-documenting
- ✅ Version controlled
- ✅ Platform independent (with minor adjustments)
