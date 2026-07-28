# Orchestrates the native PowerShell bootstrap phases. Invoked by
# bootstrap.ps1; can also be re-run directly from a cloned checkout:
#   .\windows\run.ps1

. "$PSScriptRoot\common.ps1"

if ($env:DOT_VERBOSE -eq '1') { Set-PSDebug -Trace 1 }

Select-Theme
if (-not $env:DOT_ENABLE_K8S) {
    if ((Test-IsInteractive) -and (Confirm-Action -Prompt 'Enable Kubernetes tooling (kubectl/helm/k3d)?' -Default 'y')) {
        $env:DOT_ENABLE_K8S = '1'
    } elseif (Test-IsInteractive) {
        $env:DOT_ENABLE_K8S = '0'
    } else {
        $env:DOT_ENABLE_K8S = '1'
    }
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
