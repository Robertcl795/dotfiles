# Configures the pwsh (PowerShell 7+) profile: prompt theme, PSReadLine
# predictive IntelliSense + syntax highlighting (the closest native
# equivalent to zsh's autosuggestions/highlighting), fzf/zoxide integration,
# and modern-CLI aliases matching shells/zsh/aliases.zsh.
#
# Targets pwsh's $PROFILE.CurrentUserAllHosts. Windows PowerShell 5.1 is not
# configured; install pwsh (`scoop install pwsh` runs earlier in packages.ps1
# only if requested) and use it as the default host in Windows Terminal.

$script:ManagedBeginMarker = '# >>> dotfiles managed block (do not edit by hand) >>>'
$script:ManagedEndMarker   = '# <<< dotfiles managed block <<<'

function Get-ManagedProfilePath {
    $target = $PROFILE.CurrentUserAllHosts
    if (-not $target) {
        $target = Join-Path (Split-Path $PROFILE -Parent) 'profile.ps1'
    }
    return $target
}

function New-ManagedProfileBlock {
    $themePath = "$DotfilesDir\themes\$($env:DOT_THEME)\starship.toml"

    return @"
$script:ManagedBeginMarker
# Managed by Robertcl795/dotfiles (windows/profile.ps1). Re-running the
# bootstrap replaces everything between the markers; edits outside them
# (above or below) are left alone.

`$env:STARSHIP_CONFIG = '$themePath'
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -EditMode Windows
    Set-PSReadLineOption -Colors @{
        Command   = 'Green'
        Parameter = 'Cyan'
        String    = 'Yellow'
        Comment   = 'DarkGray'
    }
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
    function ls  { eza --icons --group-directories-first @args }
    function ll  { eza -la --icons --group-directories-first @args }
}
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat @args }
}
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
}

`$env:PATH = "`$HOME\.local\bin;`$env:PATH"
$script:ManagedEndMarker
"@
}

# Idempotent: replaces the block between markers if present, appends it
# (with a backup of the existing profile) if this is the first run.
function Set-PowerShellProfile {
    Write-Step 'PowerShell profile (prompt, PSReadLine, aliases)'

    if (-not (Test-CommandExists pwsh)) {
        Write-WarnMsg 'pwsh (PowerShell 7+) not found on PATH yet; profile will still be written for when it is.'
    }

    foreach ($module in @('PSFzf')) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            } catch {
                Write-WarnMsg "Could not install PowerShell module '$module': $($_.Exception.Message)"
            }
        }
    }

    $profilePath = Get-ManagedProfilePath
    $profileDir = Split-Path $profilePath -Parent
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

    $block = New-ManagedProfileBlock

    if (Test-Path -LiteralPath $profilePath) {
        $existing = Get-Content -LiteralPath $profilePath -Raw
        if ($existing -match [regex]::Escape($script:ManagedBeginMarker)) {
            $pattern = [regex]::Escape($script:ManagedBeginMarker) + '.*?' + [regex]::Escape($script:ManagedEndMarker)
            $evaluator = [System.Text.RegularExpressions.MatchEvaluator] { param($m) $block }
            $updated = [regex]::Replace($existing, $pattern, $evaluator, [System.Text.RegularExpressions.RegexOptions]::Singleline)
            Set-Content -LiteralPath $profilePath -Value $updated -Encoding utf8
        } else {
            Backup-Item -Path $profilePath
            Add-Content -LiteralPath $profilePath -Value "`n$block`n"
        }
    } else {
        Set-Content -LiteralPath $profilePath -Value $block -Encoding utf8
    }

    Write-Info "Profile written: $profilePath"
    Write-Info "Theme: $($env:DOT_THEME) (change with: `$env:DOT_THEME=<name>; re-run bootstrap.ps1)"
}
