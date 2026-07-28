# Adds the dotfiles color schemes to Windows Terminal's settings.json and
# applies the selected one to the PowerShell profile only (not WSL profiles
# or cmd) - WSL terminal coloring/theming is handled independently on the
# Linux side by install/prompt/starship.sh.

function Get-WindowsTerminalSettingsPath {
    $candidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return $null
}

function Get-ThemeSchemeObjects {
    $themesDir = Join-Path $DotfilesDir 'themes'
    Get-ChildItem -Path $themesDir -Directory | ForEach-Object {
        $schemeFile = Join-Path $_.FullName 'windows-terminal.json'
        if (Test-Path -LiteralPath $schemeFile) {
            Get-Content -LiteralPath $schemeFile -Raw | ConvertFrom-Json
        }
    }
}

function Set-WindowsTerminalTheme {
    Write-Step 'Windows Terminal color scheme'

    $settingsPath = Get-WindowsTerminalSettingsPath
    if (-not $settingsPath) {
        Write-WarnMsg 'Windows Terminal settings.json not found; skipping (install Windows Terminal to get theming).'
        return
    }

    $raw = Get-Content -LiteralPath $settingsPath -Raw
    # settings.json ships with full-line `//` comments; strip them before
    # parsing (this is JSONC, not strict JSON) - a best-effort transform,
    # not a full JSONC parser.
    $clean = $raw -replace '(?m)^\s*//.*$', ''

    try {
        $settings = $clean | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-WarnMsg "Could not parse Windows Terminal settings.json ($($_.Exception.Message)); leaving it untouched."
        return
    }

    Backup-Item -Path $settingsPath

    $themeSchemes = Get-ThemeSchemeObjects
    if (-not $themeSchemes) {
        Write-WarnMsg 'No themes/*/windows-terminal.json files found; skipping.'
        return
    }

    $existingSchemes = @($settings.schemes)
    $keepNames = $themeSchemes | ForEach-Object { $_.name }
    $merged = @($existingSchemes | Where-Object { $keepNames -notcontains $_.name }) + $themeSchemes
    if ($settings.PSObject.Properties.Name -contains 'schemes') {
        $settings.schemes = $merged
    } else {
        $settings | Add-Member -NotePropertyName schemes -NotePropertyValue $merged -Force
    }

    $selectedName = "dotfiles-$($env:DOT_THEME)"
    if ($keepNames -notcontains $selectedName) {
        Write-WarnMsg "No Windows Terminal scheme for theme '$($env:DOT_THEME)'; leaving profile colorScheme untouched."
    } else {
        $profileList = if ($settings.profiles -is [System.Array]) { $settings.profiles } else { $settings.profiles.list }
        $matched = 0
        foreach ($p in $profileList) {
            $isPowerShell = ($p.commandline -match 'pwsh|powershell\.exe') -or
                            ($p.name -match '^PowerShell') -or
                            ($p.source -match 'PowershellCore')
            if ($isPowerShell) {
                $matched++
                if ($p.PSObject.Properties.Name -contains 'colorScheme') {
                    $p.colorScheme = $selectedName
                } else {
                    $p | Add-Member -NotePropertyName colorScheme -NotePropertyValue $selectedName -Force
                }
            }
        }
        if ($matched -eq 0) {
            Write-WarnMsg 'No PowerShell profile found in Windows Terminal settings.json; scheme added but not applied to a profile.'
        } else {
            Write-Info "Applied '$selectedName' to $matched PowerShell profile(s)."
        }
    }

    $settings | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $settingsPath -Encoding utf8
    Write-Info "Windows Terminal settings updated: $settingsPath"
    Write-WarnMsg 'Note: WSL network settings (.wslconfig / wsl.conf) are unrelated to this and are NOT touched here - see install/wsl.sh for those.'
}
