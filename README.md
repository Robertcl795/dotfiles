# Dotfiles - WSL Development Environment

Full bootstrapper for WSL Arch and WSL Ubuntu with testable checkpoints.

## Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash
```

Or:
```bash
git clone https://github.com/Robertcl795/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh
```

## Features

- One-command bootstrap (WSL Arch + WSL Ubuntu)
- Fish or Zsh (both installed; default selectable)
- Starship prompt with Tron/Cyber/Eva01 themes
- Modern CLI: bat, eza, fzf, zoxide, ripgrep, fd
- Neovim + lazy.nvim
- mise + kubectl + helm + k3d

## Customization (Interactive or Non-Interactive)

Environment variables:
```bash
DOT_SHELL=fish|zsh
DOT_THEME=tron|cyber|eva01
DOT_ENABLE_K8S=0|1
DOT_ENABLE_TMUX=0|1
DOT_NONINTERACTIVE=1
DOT_VERBOSE=1
```

Example non-interactive:
```bash
DOT_NONINTERACTIVE=1 DOT_SHELL=fish DOT_THEME=eva01 ./bootstrap.sh
```

## Tests

Run all checkpoints:
```bash
tests/99_smoke.sh
```

## Usage

Modern CLI:
```bash
ls          # eza with icons
cat file    # bat with syntax
z project   # zoxide smart cd
```

## License

MIT
