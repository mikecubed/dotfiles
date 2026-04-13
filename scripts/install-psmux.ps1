# scripts/install-psmux.ps1 — Install or update psmux via winget

$ErrorActionPreference = "Stop"

Write-Host "Checking psmux installation..."

if (Get-Command psmux -ErrorAction SilentlyContinue) {
    $current = (psmux -V 2>&1 | Select-Object -First 1).ToString().Trim()
    Write-Host "Current psmux version: $current"
    Write-Host "Checking for updates..."
    winget upgrade --id marlocarlo.psmux --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "psmux is not installed. Installing via winget..."
    winget install --id marlocarlo.psmux --accept-source-agreements --accept-package-agreements
    # Refresh PATH for current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

Write-Host "Done. psmux installed: $((psmux -V 2>&1 | Select-Object -First 1).ToString().Trim())"
