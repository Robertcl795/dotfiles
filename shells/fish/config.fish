set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache

if test -d "$HOME/.local/bin"
  fish_add_path "$HOME/.local/bin"
end

if test -d "$HOME/.fzf/bin"
  fish_add_path "$HOME/.fzf/bin"
end

set -l this_file (status --current-filename)
if test -n "$this_file"
  set -gx DOTFILES_DIR (dirname (dirname $this_file))
end

if type -q starship
  starship init fish | source
end

if type -q zoxide
  zoxide init fish | source
end

if type -q mise
  mise activate fish | source
end

if type -q fzf
  set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git/*"'
end
