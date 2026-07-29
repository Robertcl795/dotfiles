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

    # Always installed: the bootstrap itself needs these.
    foreach ($app in @('git', '7zip')) { Install-ScoopApp -Name $app }

    # Everything else comes from the selection (windows/tools.ps1).
    $selected = Get-SelectedScoopPackages
    if ($selected.Count -gt 0) {
        Write-Step "Selected packages ($($selected.Count))"
        foreach ($app in $selected) { Install-ScoopApp -Name $app }
    } else {
        Write-Info 'No scoop-installable tools selected.'
    }

    # No scoop manifest for sshs; grab the Windows release binary directly.
    if ((Test-ToolSelected 'sshs') -and -not (Test-CommandExists sshs)) {
        Install-ReleaseBinary -Name sshs -Url 'https://github.com/quantumsheep/sshs/releases/latest/download/sshs-windows-x86_64.zip'
    }

    if ((Test-ToolSelected 'rustup') -and (Test-CommandExists rustup) -and -not (Test-CommandExists rustc)) {
        try { rustup default stable | Out-Null } catch { Write-WarnMsg "rustup default stable failed: $($_.Exception.Message)" }
    }

    if (-not (Test-ToolSelected 'claude')) {
        Write-Info 'Claude Code not selected, skipping.'
    } elseif (-not (Test-CommandExists claude)) {
        try {
            Invoke-RestMethod -Uri 'https://claude.ai/install.ps1' | Invoke-Expression
        } catch {
            Write-WarnMsg "Claude Code install failed; retry later with: irm https://claude.ai/install.ps1 | iex"
        }
    }
    if ((Test-ToolSelected 'opencode') -and -not (Test-CommandExists opencode)) {
        try {
            Invoke-RestMethod -Uri 'https://opencode.ai/install.ps1' | Invoke-Expression
        } catch {
            Write-WarnMsg 'opencode install skipped (no Windows installer available or install failed).'
        }
    }

    Write-Info 'Base packages installed.'
}
