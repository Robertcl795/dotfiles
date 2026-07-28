# Phase 4 — Prompt themes (Starship)

Script: [`install/prompt/starship.sh`](../../install/prompt/starship.sh)

Installs [Starship](https://starship.rs) if it isn't already on `PATH`
(official installer script), then symlinks
`themes/<DOT_THEME>/starship.toml` to `~/.config/starship.toml` with a
timestamped backup of anything already there.

## Themes

`DOT_THEME` picks one of four, all under [`themes/`](../../themes):

| Theme | Accent | File |
| --- | --- | --- |
| `tron` | cyan | `themes/tron/starship.toml` |
| `cyber` (default) | green | `themes/cyber/starship.toml` |
| `eva01` | purple | `themes/eva01/starship.toml` |
| `radley` | blue/purple, Nerd Font icons | `themes/radley/starship.toml` |

Falls back to `cyber` with a warning if `DOT_THEME` doesn't match a
`themes/*` directory.

Switch themes any time without re-running the whole bootstrap:

```bash
DOT_THEME=tron bash install/prompt/starship.sh --run
```

## OS notes

Identical on Ubuntu and Arch — starship itself is a single static binary,
no OS-specific packaging quirks. On native Windows, the *same*
`themes/<name>/starship.toml` files are reused (via `$env:STARSHIP_CONFIG`
rather than a symlink) — see [os/windows.md](../os/windows.md) — plus each
theme also has a matching `themes/<name>/windows-terminal.json` color
scheme for the terminal itself, which has no bash-side equivalent.

## Test

[`tests/04_prompt.sh`](../../tests/04_prompt.sh) runs `starship prompt`
non-interactively and checks it exits 0.
