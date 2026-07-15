# WSL helpers — sourced by shells/zsh/zshrc (no-op outside WSL)

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  return 0
fi

# ---------- Interop shortcuts ----------
alias explorer='explorer.exe .'
alias winhome='cd "$(wslpath -u "$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d "\r")")"'

# ---------- Filesystem performance guard ----------
# Working under /mnt/* (NTFS via 9P) is 10-20x slower than native ext4.
# Warn on shell start and whenever cd lands on a Windows mount.

__wsl_fs_warn() {
  case "$PWD" in
    /mnt/*)
      if [ -z "${__WSL_FS_WARNED:-}" ]; then
        print -P "%F{yellow}[WSL] You are on a Windows NTFS mount ($PWD)." \
          "File I/O here crosses the OS boundary and is much slower." \
          "Keep repos under ~/ for native speed.%f" >&2
        __WSL_FS_WARNED=1
      fi
      ;;
    *)
      unset __WSL_FS_WARNED
      ;;
  esac
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd __wsl_fs_warn
__wsl_fs_warn
