# install.ps1 — Deploy dotfiles on Windows (PowerShell / pwsh)

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot

function Link-Config {
    param(
        [string]$Source,
        [string]$Destination
    )

    $destParent = Split-Path $Destination -Parent
    if (-not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    }

    if (Test-Path $Destination) {
        $item = Get-Item $Destination -Force
        if ($item.LinkType -eq "SymbolicLink") {
            $current = $item.Target
            if ($current -eq $Source) {
                Write-Host "  ok  $Destination -> $Source"
                return
            }
            Write-Host "  update  $Destination -> $Source (was $current)"
            Remove-Item $Destination -Force
        } else {
            $backup = "$Destination.bak"
            Write-Host "  backup  $Destination -> $backup"
            Move-Item $Destination $backup -Force
        }
    } else {
        Write-Host "  link  $Destination -> $Source"
    }

    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
}

Write-Host "Deploying dotfiles from $DotfilesDir"
Write-Host ""

# --- Neovim (LazyVim) ---
Write-Host "[nvim]"
$nvimDest = Join-Path $env:LOCALAPPDATA "nvim"
Link-Config -Source (Join-Path $DotfilesDir "nvim") -Destination $nvimDest

# --- Starship ---
Write-Host "[starship]"
$starshipDest = Join-Path $env:USERPROFILE ".config\starship.toml"
Link-Config -Source (Join-Path $DotfilesDir "starship\starship.toml") -Destination $starshipDest

# --- psmux ---
Write-Host "[psmux]"
$psmuxDest = Join-Path $env:USERPROFILE ".psmux.conf"
Link-Config -Source (Join-Path $DotfilesDir "psmux\psmux.conf") -Destination $psmuxDest

Write-Host ""
Write-Host "Symlinks created."
Write-Host ""

# --- Optional: install/update psmux ---
if (-not (Get-Command psmux -ErrorAction SilentlyContinue)) {
    $answer = Read-Host "psmux is not installed. Install latest version? [y/N]"
    if ($answer -eq "y") {
        & (Join-Path $DotfilesDir "scripts\install-psmux.ps1")
    }
} else {
    Write-Host "psmux is installed: $((psmux -V 2>&1 | Select-Object -First 1).ToString().Trim())"
    $answer = Read-Host "Check for psmux updates? [y/N]"
    if ($answer -eq "y") {
        & (Join-Path $DotfilesDir "scripts\install-psmux.ps1")
    }
}

# --- Optional: install/update neovim ---
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    $answer = Read-Host "Neovim is not installed. Install latest version? [y/N]"
    if ($answer -eq "y") {
        & (Join-Path $DotfilesDir "scripts\install-neovim.ps1")
    }
} else {
    Write-Host "Neovim is installed: $((nvim --version | Select-Object -First 1).ToString().Trim())"
    $answer = Read-Host "Check for Neovim updates? [y/N]"
    if ($answer -eq "y") {
        & (Join-Path $DotfilesDir "scripts\install-neovim.ps1")
    }
}

# --- Optional: install starship if not present ---
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    $answer = Read-Host "starship is not installed. Install it now? [y/N]"
    if ($answer -eq "y") {
        & (Join-Path $DotfilesDir "scripts\install-starship.ps1")
    }
} else {
    Write-Host "starship is already installed."
}

Write-Host ""
Write-Host "Done. You may need to:"
Write-Host "  - Restart pwsh to pick up profile changes"
Write-Host "  - Open nvim (lazy.nvim will auto-sync on first launch)"
