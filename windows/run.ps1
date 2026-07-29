# Orchestrates the native PowerShell bootstrap phases. Invoked by
# bootstrap.ps1; can also be re-run directly from a cloned checkout:
#   .\windows\run.ps1

. "$PSScriptRoot\common.ps1"

if ($env:DOT_VERBOSE -eq '1') { Set-PSDebug -Trace 1 }

# One interactive screen decides everything: which tools and which theme.
# Quitting it aborts before anything is installed.
. "$PSScriptRoot\tools.ps1"
if (-not (Resolve-ToolSelection)) { return }

if (-not $env:DOT_THEME) { Select-Theme }
if (-not $env:DOT_ENABLE_K8S) {
    $env:DOT_ENABLE_K8S = if (@('kubectl', 'helm', 'k3d') | Where-Object { Test-ToolSelected $_ }) { '1' } else { '0' }
}

Write-Step 'Starting native PowerShell bootstrap...'
Write-Info "Theme: $($env:DOT_THEME) | K8s tooling: $($env:DOT_ENABLE_K8S) | Dotfiles: $DotfilesDir"
Write-WarnMsg 'Network settings (proxy, DNS, mirrored networking) here are whatever Windows/PowerShell already uses; the WSL-specific .wslconfig/wsl.conf tuning in install/wsl.sh does not apply to this native path.'

. "$PSScriptRoot\packages.ps1"
try { Install-Packages } catch { Write-WarnMsg "Package phase hit an error, continuing: $($_.Exception.Message)" }

. "$PSScriptRoot\profile.ps1"
try { Set-PowerShellProfile } catch { Write-WarnMsg "Profile phase hit an error, continuing: $($_.Exception.Message)" }

. "$PSScriptRoot\terminal.ps1"
try { Set-WindowsTerminalTheme } catch { Write-WarnMsg "Windows Terminal phase hit an error, continuing: $($_.Exception.Message)" }

Write-Step 'Bootstrap complete.'
. "$PSScriptRoot\summary.ps1"
Show-Summary

Write-Info 'Open a new pwsh tab (or run `. $PROFILE`) to pick up the new prompt and aliases.'
