# Phase 3 — Shell setup (fish / zsh)

Scripts: [`install/shell/zsh.sh`](../../install/shell/zsh.sh),
[`install/shell/fish.sh`](../../install/shell/fish.sh)

`DOT_SHELL` (`zsh` by default, or `fish`) picks which shell is fully
configured; both get installed either way so you can try the other.

## zsh (default)

- Config is vendored from [radleylewis/zsh](https://github.com/radleylewis/zsh)
  under `config/zsh/radleylewis/` (vi-mode, autosuggestions,
  fast-syntax-highlighting, history-substring-search) and linked to
  `~/.zshrc` / `~/.config/zsh` in phase 2.
- Plugins are pre-cloned into
  `${XDG_DATA_HOME:-~/.local/share}/zsh/plugins` so the first shell launch
  is instant and works offline; re-fetch/diff upstream changes with
  `make sync-radleylewis` (runs
  [`install/shell/radleylewis.sh`](../../install/shell/radleylewis.sh)).
  Verbatim files (`bindings.zsh`, `fzf.zsh`) are overwritten on sync;
  adapted files (`aliases.zsh`, `plugins.zsh`, `prompt.zsh`) only get a
  diff printed for manual merging.
- Sets zsh as your login shell via `usermod -s` (falls back to `chsh`) —
  interactively confirmed unless `DOT_NONINTERACTIVE=1`, in which case it
  proceeds automatically when `DOT_SHELL=zsh`.

## fish

- Installs [fisher](https://github.com/jorgebucaran/fisher) as the plugin
  manager and `PatrickF1/fzf.fish` for fzf integration.
- Only offers to `chsh` to fish interactively (never in
  `DOT_NONINTERACTIVE=1` mode); the default answer is "no" — fish is
  installed either way, but zsh stays your login shell unless you say yes
  or set `DOT_SHELL=fish` and confirm.

## OS notes

Both apt (Ubuntu) and pacman (Arch) package `fish`/`zsh` directly — no
release-binary fallbacks needed here, unlike phase 1.

## Customization

`DOT_SHELL=fish|zsh`

## Test

[`tests/03_shell.sh`](../../tests/03_shell.sh) — non-interactive `fish -lc`
and `zsh -lic` startup must not error, the radleylewis config and its
plugins must be loaded, and (when `DOT_SHELL=zsh`) the login shell must
actually be zsh.
