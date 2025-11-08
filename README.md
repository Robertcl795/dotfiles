# Dotfiles - WSL Development Environment

Modern, modular dotfiles for WSL with Angular development support.

## Quick Install
```bash
wget -qO- https://raw.githubusercontent.com/YOURUSERNAME/dotfiles/main/bootstrap.sh | bash
```

## Features

- 🚀 mise - Universal version manager
- 📦 pnpm - Fast package manager
- 🐚 Zsh + Zinit - Modern shell
- ⚡ Modern CLI - bat, eza, fzf, zoxide
- 🎨 Starship - Beautiful prompt
- 🐳 Docker + K3D + Helm
- 🔧 direnv - Environment management

## What Gets Installed

All tools are optional via interactive menu:
- direnv
- mise (Node, Python, Rust)
- Docker tools
- K3D & Helm
- Zsh with Zinit
- Modern CLI tools
- Git configuration

## Documentation

- [CHEATSHEET.md](CHEATSHEET.md) - Quick reference
- [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) - Detailed setup

## Usage

### Version Management
```bash
mise use -g node@lts
mise use python@3.12
```

### Package Management
```bash
pnpm install
pnpm dev
```

### Modern CLI
```bash
ls          # eza with icons
cat file    # bat with syntax
z project   # zoxide smart cd
**<TAB>     # fzf fuzzy find
```

## Customization

Add personal aliases to `~/.zshrc.local`

## License

MIT