#Requires -Version 5.1
<#
Native Windows entry point (no WSL). Sets up PowerShell (pwsh) with the same
modern-CLI stack, Starship prompt theme and Windows Terminal color scheme
used on the WSL/bash side. Run from a cloned checkout, or one-line via:

  irm https://raw.githubusercontent.com/Robertcl795/dotfiles/main/bootstrap.ps1 | iex

For WSL Arch/Ubuntu, use bootstrap.sh instead - this script only touches the
native Windows side and does not configure or depend on any WSL distro.
#>
param(
    [switch]$NonInteractive,
    [ValidateSet('tron', 'cyber', 'eva01', 'radley')]
    [string]$Theme,
    [ValidateSet('0', '1')]
    [string]$EnableK8s,
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/Robertcl795/dotfiles.git'

if ($NonInteractive) { $env:DOT_NONINTERACTIVE = '1' }
if ($Theme) { $env:DOT_THEME = $Theme }
if ($EnableK8s) { $env:DOT_ENABLE_K8S = $EnableK8s }

function Write-BootInfo { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-BootWarn { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-BootErr  { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# $PSScriptRoot is empty when this file is piped through `iex` (no file on
# disk), same edge case bootstrap.sh handles for `curl | bash`.
$ScriptDir = $PSScriptRoot
$DotfilesDir = $env:DOTFILES_DIR
if (-not $DotfilesDir) {
    if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir '.git'))) {
        $DotfilesDir = $ScriptDir
    } elseif ($ScriptDir -and (Test-Path (Join-Path $ScriptDir 'windows'))) {
        $DotfilesDir = $ScriptDir
    } else {
        $DotfilesDir = Join-Path $HOME '.dotfiles'
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-BootInfo 'git not found. Attempting to install via winget...'
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
    } else {
        Write-BootErr 'No winget found to install git. Install Git for Windows manually, then re-run.'
        exit 1
    }
    # winget install doesn't update the current process PATH
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

if (Test-Path (Join-Path $DotfilesDir '.git')) {
    Write-BootInfo "Found existing $DotfilesDir - pulling updates..."
    try {
        Push-Location $DotfilesDir
        git pull --rebase --autostash
    } catch {
        Write-BootWarn "git pull failed, continuing with the existing checkout: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
} elseif ((Test-Path $DotfilesDir) -and (Get-ChildItem -Path $DotfilesDir -Force -ErrorAction SilentlyContinue)) {
    Write-BootWarn "$DotfilesDir exists and is not empty; using it without cloning."
} else {
    Write-BootInfo "Cloning dotfiles into $DotfilesDir (branch: $Branch)..."
    git clone --depth=1 --branch $Branch $RepoUrl $DotfilesDir
}

$env:DOTFILES_DIR = $DotfilesDir
& "$DotfilesDir\windows\run.ps1"
