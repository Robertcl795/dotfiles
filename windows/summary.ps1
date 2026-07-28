# Prints an installed-tools summary at the end of a successful native
# PowerShell bootstrap. Mirrors install/summary.sh on the WSL/bash side.

function Show-ToolRow {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$Command,
        [string]$VersionArgs
    )
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Host ('  {0,-13} {1}' -f $Label, 'not found')
        return
    }
    $version = ''
    if ($VersionArgs) {
        try {
            $version = (& $Command $VersionArgs.Split(' ') 2>$null | Select-Object -First 1)
        } catch { $version = '' }
    }
    Write-Host ('  {0,-13} {1,-10} {2}' -f $Label, 'installed', $(if ($version) { "($version)" } else { '' }))
}

function Show-Summary {
    Write-Step 'Installed tools summary'

    Write-Host ''
    Write-Host 'Shell + prompt:'
    Show-ToolRow -Label 'pwsh' -Command pwsh -VersionArgs '--version'
    Show-ToolRow -Label 'starship' -Command starship -VersionArgs '--version'
    Write-Host "  theme:        $($env:DOT_THEME)"

    Write-Host ''
    Write-Host 'Modern CLI:'
    Show-ToolRow -Label 'eza' -Command eza -VersionArgs '--version'
    Show-ToolRow -Label 'bat' -Command bat -VersionArgs '--version'
    Show-ToolRow -Label 'fd' -Command fd -VersionArgs '--version'
    Show-ToolRow -Label 'ripgrep' -Command rg -VersionArgs '--version'
    Show-ToolRow -Label 'fzf' -Command fzf -VersionArgs '--version'
    Show-ToolRow -Label 'zoxide' -Command zoxide -VersionArgs '--version'
    Show-ToolRow -Label 'zellij' -Command zellij -VersionArgs '--version'
    Show-ToolRow -Label 'just' -Command just -VersionArgs '--version'
    Show-ToolRow -Label 'lazygit' -Command lazygit -VersionArgs '--version'
    Show-ToolRow -Label 'lazydocker' -Command lazydocker
    Show-ToolRow -Label 'glow' -Command glow -VersionArgs '--version'
    Show-ToolRow -Label 'duf' -Command duf -VersionArgs '--version'
    Show-ToolRow -Label 'yazi' -Command yazi
    Show-ToolRow -Label 'sshs' -Command sshs
    Show-ToolRow -Label 'lnav' -Command lnav

    Write-Host ''
    Write-Host 'Editor:'
    Show-ToolRow -Label 'neovim' -Command nvim -VersionArgs '--version'

    Write-Host ''
    Write-Host 'Language toolchains:'
    Show-ToolRow -Label 'rustup' -Command rustc -VersionArgs '--version'
    Show-ToolRow -Label 'fnm' -Command fnm -VersionArgs '--version'
    Show-ToolRow -Label 'uv' -Command uv -VersionArgs '--version'

    if ($env:DOT_ENABLE_K8S -eq '1') {
        Write-Host ''
        Write-Host 'Kubernetes:'
        Show-ToolRow -Label 'kubectl' -Command kubectl -VersionArgs '--client=true'
        Show-ToolRow -Label 'helm' -Command helm
        Show-ToolRow -Label 'k3d' -Command k3d
    }

    Write-Host ''
    Write-Host 'AI tooling:'
    Show-ToolRow -Label 'claude' -Command claude -VersionArgs '--version'
    Show-ToolRow -Label 'gh' -Command gh -VersionArgs '--version'
    Show-ToolRow -Label 'opencode' -Command opencode -VersionArgs '--version'

    Write-Host ''
    Write-Info 'Windows Terminal profile + PowerShell $PROFILE were updated; open a new tab to see the theme.'
}
