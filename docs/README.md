# Documentation

Reference docs for every bootstrap phase and every supported OS. Start at
the root [README.md](../README.md) for install one-liners; come here for
what each phase actually does, which files it touches, and how to tune it.

## Bootstrap phases (WSL Arch / WSL Ubuntu, via `bootstrap.sh`)

Phases run in this order (`install/run.sh`); the number is what `log_step`
prints during a run and what each `tests/NN_*.sh` checkpoint validates.

| Phase | Script | Doc |
| --- | --- | --- |
| 0 | `install/detect_os.sh` | [00-preflight.md](sections/00-preflight.md) |
| 1 | `install/packages/{ubuntu,arch}.sh` | [01-packages.md](sections/01-packages.md) |
| 2 | `install/link.sh` | [02-linking.md](sections/02-linking.md) |
| 3 | `install/shell/{fish,zsh}.sh` | [03-shell.md](sections/03-shell.md) |
| 4 | `install/prompt/starship.sh` | [04-prompt.md](sections/04-prompt.md) |
| 5 | `install/nvim.sh` | [05-nvim.md](sections/05-nvim.md) |
| 6 | `install/dev/k8s.sh` | [06-kubernetes.md](sections/06-kubernetes.md) |
| 7 | `install/zellij.sh` | [07-zellij.md](sections/07-zellij.md) |
| 8 | `install/dev/lang.sh` | [08-lang-toolchains.md](sections/08-lang-toolchains.md) |
| 9 | `install/dev/ai.sh` | [09-ai-tooling.md](sections/09-ai-tooling.md) |
| 10 | `install/wsl.sh` | [10-wsl.md](sections/10-wsl.md) |
| 11 | `install/ai.sh` | [11-ai-standard.md](sections/11-ai-standard.md) |
| — | `install/summary.sh` | [12-summary.md](sections/12-summary.md) (printed automatically after phase 11 on a successful run) |

## Native Windows (PowerShell, via `bootstrap.ps1`)

No WSL involved — see [os/windows.md](os/windows.md) for the full phase
breakdown (`windows/packages.ps1`, `windows/profile.ps1`,
`windows/terminal.ps1`, `windows/summary.ps1`).

## OS-specific notes

- [os/ubuntu.md](os/ubuntu.md)
- [os/arch.md](os/arch.md)
- [os/windows.md](os/windows.md)

## Also see

- [CHEATSHEET.md](CHEATSHEET.md) — day-to-day command reference once installed.
- [../ai/README.md](../ai/README.md) — the AI Development Standard deployed by phase 11.
