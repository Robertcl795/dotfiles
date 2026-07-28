# Shared helpers for the native PowerShell bootstrap (windows/*.ps1).
# Mirrors install/common.sh (logging, backups, confirm prompts) so the two
# bootstrap paths (WSL bash / native PowerShell) behave the same way.

# windows/*.ps1 files are dot-sourced (not imported as a module), so plain
# variables here land directly in the caller's scope and stay visible to
# every other dot-sourced file in the same run.
$DotfilesDir = $env:DOTFILES_DIR
if (-not $DotfilesDir) {
    $DotfilesDir = (Resolve-Path "$PSScriptRoot\..").Path
}
$env:DOTFILES_DIR = $DotfilesDir

$env:DOT_NONINTERACTIVE = $(if ($env:DOT_NONINTERACTIVE) { $env:DOT_NONINTERACTIVE } else { '0' })
$env:DOT_VERBOSE        = $(if ($env:DOT_VERBOSE)        { $env:DOT_VERBOSE }        else { '0' })
$env:DOT_THEME          = $env:DOT_THEME
$env:DOT_ENABLE_K8S     = $env:DOT_ENABLE_K8S

function Write-Info    { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-WarnMsg { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-ErrMsg  { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Step    { param([string]$Message) Write-Host "==> $Message" -ForegroundColor Blue }

function Test-IsInteractive {
    return (-not [Console]::IsInputRedirected) -and ($env:DOT_NONINTERACTIVE -ne '1')
}

function Confirm-Action {
    param(
        [string]$Prompt = 'Continue?',
        [string]$Default = 'y'
    )
    if (-not (Test-IsInteractive)) {
        return ($Default -eq 'y')
    }
    $suffix = if ($Default -eq 'y') { '(Y/n)' } else { '(y/N)' }
    $reply = Read-Host "$Prompt $suffix"
    if ($Default -eq 'y') {
        return ($reply -notmatch '^[Nn]$')
    }
    return ($reply -match '^[Yy]$')
}

# Copies $Path to "$Path.backup.<timestamp>" if it exists. Never deletes.
function Backup-Item {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backup = "$Path.backup.$ts"
        Write-WarnMsg "Backing up $Path -> $backup"
        Copy-Item -LiteralPath $Path -Destination $backup -Recurse -Force
    }
}

function Test-CommandExists {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Select-Theme {
    if ($env:DOT_THEME) { return }
    if (-not (Test-IsInteractive)) {
        $env:DOT_THEME = 'cyber'
        return
    }
    Write-Info 'Choose a Starship theme:'
    Write-Host '1) tron'
    Write-Host '2) cyber'
    Write-Host '3) eva01'
    Write-Host '4) radley'
    $choice = Read-Host 'Select [1-4] (default 2)'
    $env:DOT_THEME = switch ($choice) {
        '1' { 'tron' }
        '3' { 'eva01' }
        '4' { 'radley' }
        default { 'cyber' }
    }
}
