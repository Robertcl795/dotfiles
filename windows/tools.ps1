# Tool registry + interactive picker for the native-Windows path.
#
# Deliberately mirrors install/tools.sh + install/select.sh: same tool ids,
# same categories, same keys, so the two bootstraps feel like one product.
# The scoop column comes from the same source of truth as the bash side —
# keep the two registries in step when adding a tool.

$script:ToolCategories = @(
    @{ Id = 'cli';    Label = 'CLI stack';  Hint = 'Modern replacements for the classic Unix tools' }
    @{ Id = 'prompt'; Label = 'Prompt';     Hint = 'Shell prompt and colour theme' }
    @{ Id = 'editor'; Label = 'Editor';     Hint = 'Neovim and its plugin manager' }
    @{ Id = 'lang';   Label = 'Languages';  Hint = 'Toolchain managers' }
    @{ Id = 'k8s';    Label = 'Kubernetes'; Hint = 'Local cluster tooling' }
    @{ Id = 'ai';     Label = 'AI tools';   Hint = 'Agentic CLIs' }
)

# Scoop = '-' means "no manifest, a custom installer handles it";
# 'x' means "not available on Windows at all".
$script:ToolRegistry = @(
    @{ Id = 'bat';        Cat = 'cli';    Label = 'bat';            Desc = 'cat with syntax highlighting and paging';   Default = $true;  Scoop = 'bat' }
    @{ Id = 'eza';        Cat = 'cli';    Label = 'eza';            Desc = 'ls with icons, git status and tree mode';   Default = $true;  Scoop = 'eza' }
    @{ Id = 'ripgrep';    Cat = 'cli';    Label = 'ripgrep';        Desc = 'grep that respects .gitignore, much faster'; Default = $true; Scoop = 'ripgrep' }
    @{ Id = 'fd';         Cat = 'cli';    Label = 'fd';             Desc = 'find with sane defaults';                   Default = $true;  Scoop = 'fd' }
    @{ Id = 'fzf';        Cat = 'cli';    Label = 'fzf';            Desc = 'fuzzy finder - history, files, completion'; Default = $true;  Scoop = 'fzf' }
    @{ Id = 'zoxide';     Cat = 'cli';    Label = 'zoxide';         Desc = 'cd that learns the directories you use';    Default = $true;  Scoop = 'zoxide' }
    @{ Id = 'duf';        Cat = 'cli';    Label = 'duf';            Desc = 'readable df';                               Default = $true;  Scoop = 'duf' }
    @{ Id = 'tldr';       Cat = 'cli';    Label = 'tldr';           Desc = 'example-first command help';                Default = $false; Scoop = 'x' }
    @{ Id = 'lazygit';    Cat = 'cli';    Label = 'lazygit';        Desc = 'full git TUI';                              Default = $true;  Scoop = 'lazygit' }
    @{ Id = 'lazydocker'; Cat = 'cli';    Label = 'lazydocker';     Desc = 'container and log TUI';                     Default = $true;  Scoop = 'lazydocker' }
    @{ Id = 'yazi';       Cat = 'cli';    Label = 'yazi';           Desc = "file manager that cd's you where you left off"; Default = $true; Scoop = 'yazi' }
    @{ Id = 'glow';       Cat = 'cli';    Label = 'glow';           Desc = 'render Markdown in the terminal';           Default = $true;  Scoop = 'glow' }
    @{ Id = 'lnav';       Cat = 'cli';    Label = 'lnav';           Desc = 'log navigator with parsing and filters';    Default = $true;  Scoop = 'lnav' }
    @{ Id = 'sshs';       Cat = 'cli';    Label = 'sshs';           Desc = 'fuzzy picker over your ~/.ssh/config';      Default = $true;  Scoop = '-' }
    @{ Id = 'just';       Cat = 'cli';    Label = 'just';           Desc = 'per-project task runner';                   Default = $true;  Scoop = 'just' }
    @{ Id = 'zellij';     Cat = 'cli';    Label = 'zellij';         Desc = 'terminal multiplexer (replaces tmux)';      Default = $true;  Scoop = 'zellij' }
    @{ Id = 'fastfetch';  Cat = 'cli';    Label = 'fastfetch';      Desc = 'greeting banner on every new shell';        Default = $true;  Scoop = 'fastfetch' }
    @{ Id = 'starship';   Cat = 'prompt'; Label = 'starship';       Desc = 'cross-shell prompt, themed';                Default = $true;  Scoop = 'starship' }
    @{ Id = 'neovim';     Cat = 'editor'; Label = 'Neovim';         Desc = 'editor, config and plugin manager';         Default = $true;  Scoop = 'neovim' }
    @{ Id = 'rustup';     Cat = 'lang';   Label = 'rustup';         Desc = 'Rust toolchain manager';                    Default = $true;  Scoop = 'rustup' }
    @{ Id = 'fnm';        Cat = 'lang';   Label = 'fnm';            Desc = 'Fast Node Manager, auto-switches on cd';    Default = $true;  Scoop = 'fnm' }
    @{ Id = 'uv';         Cat = 'lang';   Label = 'uv';             Desc = 'Python packages and environments';          Default = $true;  Scoop = 'uv' }
    @{ Id = 'kubectl';    Cat = 'k8s';    Label = 'kubectl';        Desc = 'Kubernetes CLI';                            Default = $true;  Scoop = 'kubectl' }
    @{ Id = 'helm';       Cat = 'k8s';    Label = 'helm';           Desc = 'chart package manager';                     Default = $true;  Scoop = 'helm' }
    @{ Id = 'k3d';        Cat = 'k8s';    Label = 'k3d';            Desc = 'local k3s clusters (needs Docker Desktop)'; Default = $true;  Scoop = 'k3d' }
    @{ Id = 'claude';     Cat = 'ai';     Label = 'Claude Code';    Desc = 'agentic coding CLI';                        Default = $true;  Scoop = '-' }
    @{ Id = 'opencode';   Cat = 'ai';     Label = 'opencode';       Desc = 'open-source coding agent';                  Default = $true;  Scoop = '-' }
    @{ Id = 'gh';         Cat = 'ai';     Label = 'GitHub CLI';     Desc = 'gh, plus the gh-copilot extension';         Default = $true;  Scoop = 'gh' }
)

$script:SettingRegistry = @(
    @{ Id = 'DOT_THEME'; Cat = 'prompt'; Label = 'Theme'; Desc = 'prompt colours - see docs/THEMES.md';
       Values = @('cyber', 'tron', 'eva01', 'minimal'); Default = 'cyber' }
)

function Get-SelectionPath {
    return (Join-Path $HOME '.config\rocker-dotfiles\selection.conf')
}

function Get-DefaultToolSelection {
    return @($script:ToolRegistry | Where-Object { $_.Default } | ForEach-Object { $_.Id })
}

function Test-ToolSelected {
    param([Parameter(Mandatory)][string]$Id)
    if (-not $env:DOT_TOOLS) { return $false }
    return ($env:DOT_TOOLS -split '[,\s]+') -contains $Id
}

# Scoop package names for the selected tools scoop can actually install.
function Get-SelectedScoopPackages {
    return @(
        $script:ToolRegistry |
            Where-Object { (Test-ToolSelected $_.Id) -and $_.Scoop -ne '-' -and $_.Scoop -ne 'x' } |
            ForEach-Object { $_.Scoop }
    )
}

function Save-ToolSelection {
    $path = Get-SelectionPath
    New-Item -ItemType Directory -Force -Path (Split-Path $path -Parent) | Out-Null
    @(
        '# Written by windows/tools.ps1 - edit freely, or re-run the picker.'
        "DOT_SHELL=pwsh"
        "DOT_THEME=$($env:DOT_THEME)"
        "DOT_TOOLS=`"$($env:DOT_TOOLS)`""
    ) | Set-Content -LiteralPath $path -Encoding utf8
    Write-Info "Selection saved to $path"
}

function Import-ToolSelection {
    $path = Get-SelectionPath
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    foreach ($line in (Get-Content -LiteralPath $path)) {
        if ($line -match '^\s*#' -or -not $line.Trim()) { continue }
        $key, $value = $line -split '=', 2
        $value = $value.Trim('"')
        switch ($key.Trim()) {
            'DOT_THEME' { if (-not $env:DOT_THEME) { $env:DOT_THEME = $value } }
            'DOT_TOOLS' { if (-not $env:DOT_TOOLS) { $env:DOT_TOOLS = $value } }
        }
    }
    return $true
}

# ---------------------------------------------------------------------------
# The picker
# ---------------------------------------------------------------------------

function Show-ToolPicker {
    # Rows: @{ Kind = 'head'|'tool'|'set'; Id; Label; Desc }
    $rows = @()
    foreach ($cat in $script:ToolCategories) {
        $rows += @{ Kind = 'head'; Id = $cat.Id; Label = $cat.Label; Desc = $cat.Hint }
        foreach ($s in ($script:SettingRegistry | Where-Object { $_.Cat -eq $cat.Id })) {
            $rows += @{ Kind = 'set'; Id = $s.Id; Label = $s.Label; Desc = $s.Desc }
        }
        foreach ($t in ($script:ToolRegistry | Where-Object { $_.Cat -eq $cat.Id })) {
            $rows += @{ Kind = 'tool'; Id = $t.Id; Label = $t.Label; Desc = $t.Desc }
        }
    }

    $selected = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($id in ($env:DOT_TOOLS -split '[,\s]+' | Where-Object { $_ })) { [void]$selected.Add($id) }
    if ($selected.Count -eq 0) {
        foreach ($id in (Get-DefaultToolSelection)) { [void]$selected.Add($id) }
    }
    if (-not $env:DOT_THEME) { $env:DOT_THEME = 'cyber' }

    $cursor = ($rows | ForEach-Object { $_.Kind }).IndexOf('tool')
    if ($cursor -lt 0) { $cursor = 1 }

    [Console]::CursorVisible = $false
    try {
        while ($true) {
            Clear-Host
            Write-Host ''
            Write-Host '  ROCKER LABS DOTFILES' -ForegroundColor Magenta
            Write-Host '  Choose what to install. Nothing is installed until you confirm.' -ForegroundColor DarkGray
            Write-Host ''
            Write-Host '  up/down move   space toggle   left/right change value   a/n section all/none' -ForegroundColor Cyan
            Write-Host '  A/N everything   enter install   q quit' -ForegroundColor Cyan
            Write-Host ''

            for ($i = 0; $i -lt $rows.Count; $i++) {
                $row = $rows[$i]
                $marker = if ($i -eq $cursor) { '>' } else { ' ' }
                switch ($row.Kind) {
                    'head' {
                        Write-Host ''
                        Write-Host ("    {0}  " -f $row.Label) -ForegroundColor Magenta -NoNewline
                        Write-Host $row.Desc -ForegroundColor DarkGray
                    }
                    'tool' {
                        $box = if ($selected.Contains($row.Id)) { '[x]' } else { '[ ]' }
                        $color = if ($selected.Contains($row.Id)) { 'Green' } else { 'DarkGray' }
                        Write-Host (" {0} {1} " -f $marker, $box) -ForegroundColor $color -NoNewline
                        Write-Host ("{0,-16}" -f $row.Label) -NoNewline
                        Write-Host $row.Desc -ForegroundColor DarkGray
                    }
                    'set' {
                        $value = [Environment]::GetEnvironmentVariable($row.Id)
                        Write-Host (" {0} < {1,-9} > " -f $marker, $value) -ForegroundColor Cyan -NoNewline
                        Write-Host ("{0,-14}" -f $row.Label) -NoNewline
                        Write-Host $row.Desc -ForegroundColor DarkGray
                    }
                }
            }

            Write-Host ''
            Write-Host ("  {0} of {1} tools selected" -f $selected.Count, $script:ToolRegistry.Count)

            $key = [Console]::ReadKey($true)
            $row = $rows[$cursor]

            switch ($key.Key) {
                'UpArrow' {
                    for ($i = $cursor - 1; $i -ge 0; $i--) {
                        if ($rows[$i].Kind -ne 'head') { $cursor = $i; break }
                    }
                }
                'DownArrow' {
                    for ($i = $cursor + 1; $i -lt $rows.Count; $i++) {
                        if ($rows[$i].Kind -ne 'head') { $cursor = $i; break }
                    }
                }
                'Spacebar' {
                    if ($row.Kind -eq 'tool') {
                        if ($selected.Contains($row.Id)) { [void]$selected.Remove($row.Id) }
                        else { [void]$selected.Add($row.Id) }
                    } elseif ($row.Kind -eq 'set') {
                        Step-Setting -Id $row.Id -Direction 1
                    }
                }
                'RightArrow' { if ($row.Kind -eq 'set') { Step-Setting -Id $row.Id -Direction 1 } }
                'LeftArrow'  { if ($row.Kind -eq 'set') { Step-Setting -Id $row.Id -Direction -1 } }
                'Enter' { return @{ Tools = @($selected); Cancelled = $false } }
                default {
                    switch ($key.KeyChar) {
                        'a' {
                            $cat = Get-RowCategory -Rows $rows -Index $cursor
                            foreach ($t in ($script:ToolRegistry | Where-Object { $_.Cat -eq $cat })) { [void]$selected.Add($t.Id) }
                        }
                        'n' {
                            $cat = Get-RowCategory -Rows $rows -Index $cursor
                            foreach ($t in ($script:ToolRegistry | Where-Object { $_.Cat -eq $cat })) { [void]$selected.Remove($t.Id) }
                        }
                        'A' { foreach ($t in $script:ToolRegistry) { [void]$selected.Add($t.Id) } }
                        'N' { $selected.Clear() }
                        'q' { return @{ Tools = @(); Cancelled = $true } }
                        'Q' { return @{ Tools = @(); Cancelled = $true } }
                    }
                }
            }
        }
    } finally {
        [Console]::CursorVisible = $true
    }
}

function Get-RowCategory {
    param([Parameter(Mandatory)]$Rows, [Parameter(Mandatory)][int]$Index)
    for ($i = $Index; $i -ge 0; $i--) {
        if ($Rows[$i].Kind -eq 'head') { return $Rows[$i].Id }
    }
    return ''
}

function Step-Setting {
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][int]$Direction)
    $setting = $script:SettingRegistry | Where-Object { $_.Id -eq $Id } | Select-Object -First 1
    if (-not $setting) { return }
    $current = [Environment]::GetEnvironmentVariable($Id)
    $index = [array]::IndexOf($setting.Values, $current)
    if ($index -lt 0) { $index = 0 }
    $index = ($index + $Direction) % $setting.Values.Count
    if ($index -lt 0) { $index += $setting.Values.Count }
    Set-Item -Path "env:$Id" -Value $setting.Values[$index]
}

# Resolve the selection: an explicit $env:DOT_TOOLS wins, then a saved
# answer, then the picker (or the registry defaults when non-interactive).
function Resolve-ToolSelection {
    Write-Step 'Tool selection'

    if ($env:DOT_TOOLS) {
        Write-Info "Using DOT_TOOLS from the environment: $env:DOT_TOOLS"
        return $true
    }

    Import-ToolSelection | Out-Null

    if ($env:DOT_NONINTERACTIVE -eq '1' -or -not (Test-IsInteractive)) {
        if (-not $env:DOT_TOOLS) {
            $env:DOT_TOOLS = (Get-DefaultToolSelection) -join ' '
        }
        Write-Info "Tools: $env:DOT_TOOLS"
        return $true
    }

    $result = Show-ToolPicker
    Clear-Host
    if ($result.Cancelled) {
        Write-WarnMsg 'Cancelled - nothing was installed.'
        return $false
    }

    $env:DOT_TOOLS = ($result.Tools -join ' ')
    $env:DOT_ENABLE_K8S = if (@('kubectl', 'helm', 'k3d') | Where-Object { Test-ToolSelected $_ }) { '1' } else { '0' }
    Save-ToolSelection
    Write-Info "Tools: $env:DOT_TOOLS"
    return $true
}
