# Configures the pwsh (PowerShell 7+) profile: prompt theme, PSReadLine
# predictive IntelliSense + syntax highlighting (the closest native
# equivalent to zsh's autosuggestions/highlighting), fzf/zoxide integration,
# modern-CLI and git aliases matching config/zsh/{aliases,git}.zsh, and the
# fastfetch greeting.
#
# Targets pwsh's $PROFILE.CurrentUserAllHosts. pwsh is NOT installed by
# packages.ps1 (no `pwsh` scoop app in its core list) and $PROFILE resolves
# relative to whichever host is currently running this script - so this must
# be run from inside pwsh for the block to land in pwsh's profile path.
# Running the bootstrap from Windows PowerShell 5.1 instead writes the block
# to 5.1's own profile.ps1, which pwsh never reads. Install pwsh yourself
# first (`winget install Microsoft.PowerShell` or `scoop install pwsh`) and
# set it as the default host in Windows Terminal.

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
# Managed by Rocker Labs Dotfiles (windows/profile.ps1). Re-running the
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

# Git aliases — mirror of config/zsh/git.zsh. PowerShell resolves aliases
# before functions, so the built-ins these names collide with (gc =
# Get-Content, gcm = Get-Command, gl = Get-Location, gp = Get-ItemProperty)
# have to be removed first or they would win.
if (Get-Command git -ErrorAction SilentlyContinue) {
    foreach (`$builtin in 'gc', 'gcm', 'gl', 'gp') {
        Remove-Item "alias:`$builtin" -Force -ErrorAction SilentlyContinue
    }

    function gst   { git status @args }
    function gss   { git status --short --branch @args }
    function ga    { git add @args }
    function gaa   { git add --all @args }
    function gap   { git add --patch @args }
    function grs   { git restore @args }
    function grst  { git restore --staged @args }

    function gc    { git commit -v @args }
    function gcm   { git commit -v -m @args }
    function gca   { git commit -v --amend @args }
    function gcan  { git commit -v --amend --no-edit @args }
    function gcf   { git commit --fixup @args }

    function gco   { git checkout @args }
    function gcob  { git checkout -b @args }
    function gsw   { git switch @args }
    function gswc  { git switch -c @args }
    function gswd  { git switch --detach @args }

    function gb    { git branch @args }
    function gba   { git branch --all @args }
    function gbd   { git branch -d @args }
    function gbD   { git branch -D @args }
    function gbv   { git branch -vv @args }

    function gd    { git diff @args }
    function gds   { git diff --staged @args }
    function gdw   { git diff --word-diff @args }
    function gl    { git log --oneline --graph --decorate -20 @args }
    function glog  { git log @args }
    function gadog { git log --all --decorate --oneline --graph @args }

    function gf    { git fetch --all --prune @args }
    function gpl   { git pull --rebase --autostash @args }
    function gp    { git push @args }
    function gpu   { git push -u origin HEAD @args }
    function gpf   { git push --force-with-lease @args }

    function gsta  { git stash push @args }
    function gstp  { git stash pop @args }
    function gstl  { git stash list @args }
    function grb   { git rebase @args }
    function grbi  { git rebase -i @args }
    function grbc  { git rebase --continue @args }
    function grba  { git rebase --abort @args }
    function gwt   { git worktree @args }
}

`$env:PATH = "`$HOME\.local\bin;`$env:PATH"

# Greeting: fastfetch on every new tab (set DOT_NO_FASTFETCH=1 to skip).
if ((-not `$env:DOT_NO_FASTFETCH) -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    fastfetch
}
$script:ManagedEndMarker
"@
}

# fastfetch reads ~/.config/fastfetch/config.jsonc. A directory junction
# needs no admin rights (unlike a symlink), so the repo config stays the
# single source of truth on Windows too; a copy is the fallback.
function Set-FastfetchConfig {
    $target = Join-Path $HOME '.config\fastfetch'
    $source = Join-Path $DotfilesDir 'config\fastfetch'

    if (-not (Test-Path -LiteralPath $source)) { return }
    if (Test-Path -LiteralPath $target) {
        $item = Get-Item -LiteralPath $target -Force
        if ($item.LinkType -in @('Junction', 'SymbolicLink')) { return }
        Backup-Item -Path $target
        Remove-Item -LiteralPath $target -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    try {
        New-Item -ItemType Junction -Path $target -Target $source -ErrorAction Stop | Out-Null
        Write-Info "fastfetch config linked: $target -> $source"
    } catch {
        Copy-Item -Path $source -Destination $target -Recurse -Force
        Write-WarnMsg "Could not create a junction; copied the fastfetch config to $target instead (re-run the bootstrap after changing it)."
    }
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

    Set-FastfetchConfig

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
