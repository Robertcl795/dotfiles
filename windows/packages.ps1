# Native Windows package installation (scoop). Mirrors the intent of
# install/packages/ubuntu.sh and install/packages/arch.sh but targets a
# fresh Windows machine with no WSL involved.

function Install-Scoop {
    if (Test-CommandExists scoop) { return }
    Write-Info 'Installing scoop (Windows package manager)...'
    if ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'Restricted') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    }
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}

function Install-ScoopBucket {
    param([Parameter(Mandatory)][string]$Name)
    $buckets = (scoop bucket list 2>$null | Out-String)
    if ($buckets -notmatch "(?m)^$Name(\s|$)") {
        scoop bucket add $Name | Out-Null
    }
}

# Installs one scoop package, tolerating failure so one missing/renamed
# manifest never aborts the rest of the run (mirrors `|| log_warn` in bash).
function Install-ScoopApp {
    param([Parameter(Mandatory)][string]$Name)
    if (Test-CommandExists $Name) { return }
    Write-Info "Installing $Name via scoop..."
    try {
        scoop install $Name 2>&1 | Out-Null
    } catch {
        Write-WarnMsg "scoop could not install '$Name': $($_.Exception.Message)"
    }
}

# Downloads a single-binary GitHub release asset (zip only) into
# %USERPROFILE%\.local\bin for tools with no scoop manifest (e.g. sshs).
function Install-ReleaseBinary {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url,
        [string]$ExeNameInArchive
    )
    if (Test-CommandExists $Name) { return }
    $binDir = "$HOME\.local\bin"
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    $tmp = New-Item -ItemType Directory -Force -Path (Join-Path $env:TEMP "dotfiles-$Name-$(Get-Random)")
    try {
        $archive = Join-Path $tmp "$Name.zip"
        Invoke-WebRequest -Uri $Url -OutFile $archive -UseBasicParsing
        Expand-Archive -Path $archive -DestinationPath $tmp -Force
        $exePattern = if ($ExeNameInArchive) { $ExeNameInArchive } else { "$Name.exe" }
        $exe = Get-ChildItem -Path $tmp -Recurse -Filter $exePattern | Select-Object -First 1
        if (-not $exe) {
            Write-WarnMsg "No $exePattern found in release asset for $Name."
            return
        }
        Copy-Item -Path $exe.FullName -Destination (Join-Path $binDir "$Name.exe") -Force
        Write-Info "$Name installed to $binDir\$Name.exe"
    } catch {
        Write-WarnMsg "Could not install $Name from release asset: $($_.Exception.Message)"
    } finally {
        Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
}

function Add-LocalBinToPath {
    $binDir = "$HOME\.local\bin"
    if ($env:Path -notlike "*$binDir*") {
        $env:Path = "$binDir;$env:Path"
    }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$binDir*") {
        [Environment]::SetEnvironmentVariable('Path', "$binDir;$userPath", 'User')
    }
}

function Install-Packages {
    Write-Step 'Base packages (scoop)'
    Install-Scoop
    Install-ScoopBucket -Name extras
    Install-ScoopBucket -Name versions
    Add-LocalBinToPath

    Write-Step 'Modern CLI stack'
    $coreApps = @(
        'git', '7zip', 'starship', 'ripgrep', 'fd', 'bat', 'eza', 'fzf',
        'zoxide', 'neovim', 'lazygit', 'glow', 'duf', 'lnav', 'just',
        'zellij', 'yazi', 'lazydocker'
    )
    foreach ($app in $coreApps) { Install-ScoopApp -Name $app }

    # No scoop manifest for sshs; grab the Windows release binary directly.
    if (-not (Test-CommandExists sshs)) {
        Install-ReleaseBinary -Name sshs -Url 'https://github.com/quantumsheep/sshs/releases/latest/download/sshs-windows-x86_64.zip'
    }

    Write-Step 'Language toolchains (rustup / fnm / uv)'
    foreach ($app in @('rustup', 'fnm', 'uv')) { Install-ScoopApp -Name $app }
    if ((Test-CommandExists rustup) -and -not (Test-CommandExists rustc)) {
        try { rustup default stable | Out-Null } catch { Write-WarnMsg "rustup default stable failed: $($_.Exception.Message)" }
    }

    if ($env:DOT_ENABLE_K8S -eq '1') {
        Write-Step 'Kubernetes tooling (kubectl / helm / k3d)'
        foreach ($app in @('kubectl', 'helm', 'k3d')) { Install-ScoopApp -Name $app }
    } else {
        Write-Info 'K8s tooling disabled (DOT_ENABLE_K8S=0).'
    }

    Write-Step 'AI tooling (claude / gh / opencode)'
    Install-ScoopApp -Name gh
    if (-not (Test-CommandExists claude)) {
        try {
            Invoke-RestMethod -Uri 'https://claude.ai/install.ps1' | Invoke-Expression
        } catch {
            Write-WarnMsg "Claude Code install failed; retry later with: irm https://claude.ai/install.ps1 | iex"
        }
    }
    if (-not (Test-CommandExists opencode)) {
        try {
            Invoke-RestMethod -Uri 'https://opencode.ai/install.ps1' | Invoke-Expression
        } catch {
            Write-WarnMsg 'opencode install skipped (no Windows installer available or install failed).'
        }
    }

    Write-Info 'Base packages installed.'
}
