# Dotfiles - WSL Development Environment

Full bootstrapper for WSL Arch and WSL Ubuntu with testable checkpoints.

## Quick Install

From `main`:
```bash
curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash
```

From a feature branch (replace with the branch you are testing — currently
`claude/dotfiles-rust-web-refactor-8kcsxv`):
```bash
BRANCH=claude/dotfiles-rust-web-refactor-8kcsxv
curl -fsSL "https://raw.githubusercontent.com/Robertcl795/dotfiles/$BRANCH/bootstrap.sh" | DOTFILES_BRANCH=$BRANCH bash
```

Or clone manually:
```bash
git clone https://github.com/Robertcl795/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh
```

### Fresh Arch WSL (first boot)

A brand-new `wsl -d archlinux` instance starts as **root** with no user.
Run the same bootstrap command as root: it will update the system
(`pacman -Syu`), enable sudo for the `wheel` group, prompt for a username
(`useradd -m -G wheel`), and set it as the WSL default user. Then:

```powershell
wsl --shutdown
wsl -d archlinux   # now logs in as your user
```

…and run the bootstrap again as that user to install everything else.
For non-interactive first boot, pass `DOT_USERNAME=<name>`.

> **WSL tip:** keep the repo (and your projects) under `~/`, never under
> `/mnt/c/...` — cross-OS I/O is 10-20x slower. The bootstrap moves out of
> `/mnt` automatically and the shell warns (and auto-`cd`s home) when a new
> session starts on the Windows filesystem. Opt out with `DOT_NO_AUTOCD=1`.

### Native Windows (PowerShell, no WSL)

Sets up PowerShell itself — prompt theme, modern CLI stack (via
[scoop](https://scoop.sh)), and a matching Windows Terminal color scheme.
Completely separate from the WSL path above and doesn't require a WSL
distro at all:

```powershell
irm https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.ps1 | iex
```

Full details, including why the network setup here is unrelated to
`.wslconfig`: [docs/os/windows.md](docs/os/windows.md).

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
  plus kubectl + helm + k3d
- AI tooling: **Claude Code**, **opencode**, **gh copilot**
- **AI Development Standard** (`ai/`): canonical instruction sets, specialized
  Claude agents, reusable prompts, skills and a local vector context DB
  (ChromaDB + fastembed via MCP) — deployed globally by the bootstrap and
  into any repo with `make ai-scaffold TARGET=/path/to/repo` (see
  [`ai/README.md`](ai/README.md))
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
DOT_USERNAME=<name>                # Arch first boot: user to create (non-interactive)
DOT_NO_AUTOCD=1                    # don't auto-cd to ~ when a shell starts on /mnt/*
DOTFILES_BRANCH=<branch>           # bootstrap from a branch other than main
```

Example non-interactive:
```bash
DOT_NONINTERACTIVE=1 DOT_SHELL=zsh DOT_THEME=radley ./bootstrap.sh
```

After changing WSL networking settings, run `wsl --shutdown` from PowerShell
and reopen your terminal.

`bootstrap.ps1` (native Windows) takes the equivalent options as
parameters instead of env vars: `-NonInteractive -Theme <name> -EnableK8s
0|1 -Branch <branch>`.

## Upstream sync (radleylewis)

The zsh base config is vendored under `config/zsh/radleylewis/`. To re-fetch
upstream and refresh/diff the vendored files:

```bash
make sync-radleylewis
```

## Documentation

Per-phase and per-OS docs (what each phase does, files touched,
customization, troubleshooting): [docs/README.md](docs/README.md).

## Tests

Run all checkpoints:
```bash
tests/99_smoke.sh
```

A successful bootstrap ends with an installed-tools summary (versions
where available) — see [docs/sections/12-summary.md](docs/sections/12-summary.md).

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
