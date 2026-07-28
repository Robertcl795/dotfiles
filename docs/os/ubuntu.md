# OS notes — WSL Ubuntu

Entry point: `bootstrap.sh` (auto-detects Ubuntu via `/etc/os-release`,
`ID=ubuntu`; see [00-preflight.md](../sections/00-preflight.md)).

## What's different from Arch here

Ubuntu's `apt` archive lags upstream, so this is the OS where the bootstrap
does the most work outside the package manager:

- **Release-binary fallbacks** (into `~/.local/bin`, no `sudo` needed):
  `lazygit`, `glow`, `lazydocker`, `zellij`, `yazi`, `sshs`, and `duf` if
  apt doesn't have it. Pin versions with `DOT_LAZYGIT_VERSION`,
  `DOT_GLOW_VERSION`, `DOT_LAZYDOCKER_VERSION`, `DOT_DUF_VERSION`. Details:
  [01-packages.md](../sections/01-packages.md).
- **Alternate package names**: `fd-find`→`fd`, `bat`/`batcat`→`bat`,
  `exa`→`eza` are auto-detected and symlinked to the canonical name.
- **`tldr`/`eza` install never hard-fails**: these two specifically used to
  be able to take down the *entire* bootstrap — `apt-cache show <pkg>`
  can report a package as present even when apt has no installable
  candidate for it (stale/partial index, or the package was dropped from
  the current release), which made the old pre-check a false positive; the
  subsequent `apt-get install` then failed under `set -e` and killed the
  whole run. Both now attempt install directly (inside an `if`, so a
  failure can never trip `errexit`) with a fallback package and a warning
  if neither is installable — see
  [01-packages.md](../sections/01-packages.md#ubuntu).
- Starship always comes from the official installer script here (Arch has
  a native `pacman` package instead).

## Prerequisites

A fresh WSL Ubuntu instance already boots as your regular user (unlike
Arch — no first-boot provisioning step needed here). You do need `sudo`
and a working network connection before running `bootstrap.sh`;
[00-preflight.md](../sections/00-preflight.md) checks both up front.

## Known-good install

```bash
curl -fsSL https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.sh | bash
```

or non-interactively:

```bash
DOT_NONINTERACTIVE=1 DOT_SHELL=zsh DOT_THEME=cyber ./bootstrap.sh
```
