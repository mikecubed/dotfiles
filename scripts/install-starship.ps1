# scripts/install-starship.ps1 — Install starship prompt and enable it in pwsh profile

$ErrorActionPreference = "Stop"

Write-Host "Installing starship prompt..."

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Host "starship is already installed: $(starship --version | Select-Object -First 1)"
} else {
    Write-Host "Installing via winget..."
    winget install --id Starship.Starship --accept-source-agreements --accept-package-agreements
    # Refresh PATH for current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

# Ensure pwsh profile exists and has starship init
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$initLine = 'Invoke-Expression (&starship init powershell)'
if (Select-String -Path $profilePath -Pattern 'starship init powershell' -Quiet) {
    Write-Host "starship init already in $profilePath"
} else {
    Add-Content -Path $profilePath -Value ""
    Add-Content -Path $profilePath -Value "# starship prompt"
    Add-Content -Path $profilePath -Value $initLine
    Write-Host "Added starship init to $profilePath"
}

Write-Host "Done. Restart pwsh to see the new prompt."
