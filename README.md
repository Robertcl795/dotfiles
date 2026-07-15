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

> **WSL tip:** keep the repo (and your projects) under `~/`, never under
> `/mnt/c/...` — cross-OS I/O is 10-20x slower. The bootstrap and the shell
> will warn you if you don't.

## Features

- One-command bootstrap (WSL Arch + WSL Ubuntu)
- **Zsh by default** (fish still available) with a base config vendored from
  [radleylewis/zsh](https://github.com/radleylewis/zsh): vi-mode,
  autosuggestions, fast-syntax-highlighting, history-substring-search
- Starship prompt with Tron/Cyber/Eva01/Radley themes
- Modern CLI: bat, eza, fzf, zoxide, ripgrep, fd, **lazygit, glow, duf,
  lazydocker, yazi, sshs, lnav, just**
- **Zellij** as terminal multiplexer (replaces tmux)
- Neovim + lazy.nvim
- Language toolchains: **rustup** (Rust), **fnm** (Node.js), **uv** (Python),
  plus mise + kubectl + helm + k3d
- AI tooling: **Claude Code**, **opencode**, **gh copilot**
- WSL2 optimizations: `.wslconfig` on the Windows host with
  `networkingMode=mirrored`, `dnsTunneling=true`, `autoProxy=true`
  (configured automatically via interop), systemd-enabled `/etc/wsl.conf`,
  and NTFS performance guards in the shell

## Customization (Interactive or Non-Interactive)

Environment variables:
```bash
DOT_SHELL=fish|zsh                 # default: zsh
DOT_THEME=tron|cyber|eva01|radley  # default: cyber
DOT_ENABLE_K8S=0|1
DOT_ENABLE_WSLCONFIG=0|1           # write .wslconfig on the Windows host
DOT_NONINTERACTIVE=1
DOT_VERBOSE=1
```

Example non-interactive:
```bash
DOT_NONINTERACTIVE=1 DOT_SHELL=zsh DOT_THEME=radley ./bootstrap.sh
```

After changing WSL networking settings, run `wsl --shutdown` from PowerShell
and reopen your terminal.

## Upstream sync (radleylewis)

The zsh base config is vendored under `config/zsh/radleylewis/`. To re-fetch
upstream and refresh/diff the vendored files:

```bash
make sync-radleylewis
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
y           # yazi file manager (follows directory on quit)
lg          # lazygit
ld          # lazydocker
zellij      # terminal multiplexer
just        # task runner
```

Dev stack:
```bash
rustup show           # Rust toolchain
fnm install --lts     # Node.js versions
uv venv               # fast Python envs
claude                # Claude Code
opencode              # opencode
gh copilot suggest    # Copilot CLI (after gh auth login)
```

## License

MIT
