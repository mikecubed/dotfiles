# scripts/install-neovim.ps1 — Install or update Neovim via winget

$ErrorActionPreference = "Stop"

Write-Host "Checking Neovim installation..."

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $current = (nvim --version | Select-Object -First 1).ToString().Trim()
    Write-Host "Current Neovim version: $current"
    Write-Host "Checking for updates..."
    winget upgrade --id Neovim.Neovim --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "Neovim is not installed. Installing via winget..."
    winget install --id Neovim.Neovim --accept-source-agreements --accept-package-agreements
    # Refresh PATH for current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

Write-Host "Done. Neovim installed: $((nvim --version | Select-Object -First 1).ToString().Trim())"
