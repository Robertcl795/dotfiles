# Codex Task: Make this dotfiles repo a full bootstrapper (WSL Arch + Ubuntu) with testable checkpoints

You are an expert in Linux, shell scripting, development environments, and dotfiles design.
Your job is to analyze THIS repository and implement all necessary changes so it fulfills the acceptance criteria below.

## Non-negotiable goals
1) One-command bootstrap after a fresh install (WSL Arch or WSL Ubuntu):
   - Detect OS
   - Update system
   - Install base packages
   - Clone dotfiles into the home folder (or use current repo if already present)
   - Set up shell (choice: fish or zsh) and prompt
   - Install plugin manager for chosen shell
   - Enable: icons/colors, fzf, zoxide, completions, autosuggestions, syntax highlighting, “command info/intellisense” (closest practical equivalent)
   - Setup Neovim
   - Setup dev environment: mise + k8s tooling + k3d
   - Provide 3 prompt themes: Tron/Cyber/Eva01
   - Allow customization (interactive prompts + non-interactive env vars)

2) Re-runnable and safe:
   - Idempotent (can run multiple times without breaking)
   - No silent overwrites: back up files or confirm
   - Minimal and clear logs
   - Fail fast with actionable error messages

3) Tests and checkpoints:
   - Each phase has a runnable test script
   - Works on fresh WSL Arch and fresh WSL Ubuntu
   - Tests must detect failure and exit non-zero

## Deliverables to implement in this repo
Implement/ensure the following structure (you may adapt names slightly, but keep the intent):
- bootstrap.sh (entrypoint)
- install/
  - detect_os.sh
  - packages/arch.sh
  - packages/ubuntu.sh
  - shell/fish.sh
  - shell/zsh.sh
  - prompt/starship.sh
  - nvim.sh
  - dev/mise.sh
  - dev/k8s.sh
  - tmux.sh (optional)
  - link.sh (symlink dotfiles with backup)
- themes/{tron,cyber,eva01}/starship.toml
- shells/fish/ (config.fish, fisher plugins, aliases, functions)
- shells/zsh/ (zshrc, plugin manager config, aliases)
- nvim/ (init + plugins)
- tests/ (phase tests + final smoke test)

## Required user experience
### One-liner install (must be documented)
Support:
- curl -fsSL <raw bootstrap.sh> | bash
Also support:
- git clone ... ~/.dotfiles && ~/.dotfiles/bootstrap.sh

### Customization interface
Support BOTH:
A) Interactive prompts (default if TTY)
B) Non-interactive environment vars (for automation), e.g.:
- DOT_SHELL=fish|zsh
- DOT_THEME=tron|cyber|eva01
- DOT_ENABLE_K8S=0|1
- DOT_ENABLE_TMUX=0|1
- DOT_NONINTERACTIVE=1
- DOT_VERBOSE=1

### “Command intellisense” requirement
Implement the closest practical equivalents:
- For fish: built-in autosuggestions + completions + fzf integration + (optional) `fish-autocomplete`/enhanced completions.
- For zsh: autosuggestions + completions + syntax highlighting + fzf-tab or similar.
- Also install `tldr` OR `tealdeer` and `thefuck` or `atuin` ONLY if it truly adds value. Prefer minimal.

## Mandatory phases (and each must have a test)
Implement phases in this order and create tests that validate each phase:

### Phase 0: Preflight & OS detection
- Detect WSL Ubuntu vs WSL Arch
- Check network connectivity
- Confirm required commands exist or can be installed
Test: tests/00_preflight.sh

### Phase 1: System update + base packages
- Update OS
- Install: git, curl, wget, unzip, ca-certificates, ripgrep, fd, bat, eza, fzf, zoxide, neovim, starship
- On Arch: use pacman; on Ubuntu: apt
Test: tests/01_packages.sh

### Phase 2: Clone + link dotfiles
- Clone into ~/.dotfiles (or ~/.neoncore, pick one and standardize)
- Symlink configs into ~/.config and dotfiles into ~/
- Back up existing files with timestamp suffix
Test: tests/02_linking.sh

### Phase 3: Shell setup
- Install shell if missing
- Install plugin manager (fish: fisher; zsh: zinit or antidote)
- Configure:
  - fzf integration
  - zoxide integration
  - autosuggestions
  - syntax highlighting
  - completions
- Set default shell only if allowed (in WSL it may require user action—handle gracefully)
Test: tests/03_shell.sh
  - Validate that a non-interactive shell startup does not error:
    - fish -lc "echo ok"
    - zsh -lic "echo ok"

### Phase 4: Prompt themes
- Install starship
- Provide 3 theme configs
- Switch theme by symlink to ~/.config/starship.toml
Test: tests/04_prompt.sh
  - starship prompt renders (exit 0)

### Phase 5: Neovim
- Install config into ~/.config/nvim
- Use a plugin manager (lazy.nvim preferred)
- Provide headless sync command
Test: tests/05_nvim.sh
  - nvim --headless "+Lazy! sync" +qa exits 0

### Phase 6: Dev environment (mise + k8s + k3d)
- Install mise
- Ensure mise is activated in chosen shell
- Install kubectl + helm + k3d (or document optional install via flags)
Test: tests/06_dev.sh
  - mise doctor
  - kubectl version --client
  - k3d version

### Phase 7: Final smoke test
- Single command validates everything configured
Test: tests/99_smoke.sh

## Coding requirements
- Use bash for bootstrap and install scripts (POSIX-ish, but bash ok)
- `set -euo pipefail` in scripts; handle expected failures explicitly
- Print clear steps; do not spam
- Do not ask for user input when DOT_NONINTERACTIVE=1
- Never remove user files; only back up
- Keep scripts under 300 lines each; split if needed

## What to do now
1) Inspect repository structure and current dotfiles.
2) Identify gaps vs acceptance criteria.
3) Implement the missing files and refactor existing ones as needed.
4) Ensure bootstrap.sh orchestrates phases and supports flags/env vars.
5) Ensure tests exist and pass on WSL Arch and WSL Ubuntu.

## Output format requirements
- Make actual code changes in the repository (create/modify files).
- Provide a concise CHANGELOG section at the end describing what you changed.
- Do NOT provide vague recommendations; implement them.

## Definition of done
- Running bootstrap.sh on fresh WSL Arch and fresh WSL Ubuntu results in:
  - shell configured (fish or zsh)
  - starship theme selected
  - fzf + zoxide working
  - nvim configured and plugins synced
  - mise installed and usable
  - kubectl + k3d installed if enabled
  - all tests scripts pass
