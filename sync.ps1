# sync.ps1 — Pull latest dotfiles from GitHub and re-run install

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot

Set-Location $DotfilesDir

Write-Host "Pulling latest dotfiles..."
git pull --ff-only

Write-Host ""
& (Join-Path $DotfilesDir "install.ps1")
