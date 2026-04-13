# scripts/setup-starship.ps1 — Interactive starship preset selector for Windows

$ErrorActionPreference = "Stop"

$StarshipConfig = Join-Path $env:USERPROFILE ".config\starship.toml"

# --- Preset list ---
$Presets = @(
    "bracketed-segments"
    "catppuccin-powerline"
    "gruvbox-rainbow"
    "jetpack"
    "nerd-font-symbols"
    "no-empty-icons"
    "no-nerd-font"
    "no-runtime-versions"
    "pastel-powerline"
    "plain-text-symbols"
    "pure-preset"
    "tokyo-night"
)

Write-Host "Available starship presets:"
Write-Host ""
for ($i = 0; $i -lt $Presets.Count; $i++) {
    Write-Host ("  {0,2}) {1}" -f ($i + 1), $Presets[$i])
}
Write-Host ""
Write-Host ("  {0}) Keep current config / skip" -f ($Presets.Count + 1))
Write-Host ""

do {
    $choice = Read-Host "Select a preset [1-$($Presets.Count + 1)]"
    $valid = $choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le ($Presets.Count + 1)
    if (-not $valid) { Write-Host "Invalid selection. Try again." }
} while (-not $valid)

$choice = [int]$choice

if ($choice -eq $Presets.Count + 1) {
    Write-Host "Keeping current starship config."
    return
}

$Preset = $Presets[$choice - 1]
Write-Host ""
Write-Host "Applying preset: $Preset"

$configDir = Split-Path $StarshipConfig -Parent
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

starship preset $Preset -o $StarshipConfig

# --- Post-processing ---

switch ($Preset) {
    "catppuccin-powerline" {
        Write-Host ""
        Write-Host "Catppuccin palette options:"
        Write-Host "  1) mocha  (dark, warm)"
        Write-Host "  2) frappe  (medium dark)"
        Write-Host "  3) macchiato (medium)"
        Write-Host "  4) latte  (light)"
        Write-Host ""
        do {
            $pchoice = Read-Host "Select palette [1-4]"
            $pvalid = $pchoice -match '^[1-4]$'
            if (-not $pvalid) { Write-Host "Invalid selection. Try again." }
        } while (-not $pvalid)

        $palette = switch ($pchoice) {
            "1" { "catppuccin_mocha" }
            "2" { "catppuccin_frappe" }
            "3" { "catppuccin_macchiato" }
            "4" { "catppuccin_latte" }
        }

        (Get-Content $StarshipConfig -Raw) -replace "palette = 'catppuccin_mocha'", "palette = '$palette'" |
            Set-Content $StarshipConfig -NoNewline
        Write-Host "Set palette to $palette."
    }

    "tokyo-night" {
        # Replace hardcoded Apple icon segment with $os module reference
        (Get-Content $StarshipConfig -Raw) -replace '\[.+?\]\(bg:#a3aed2 fg:#090c0c\)', '$$os' |
            Set-Content $StarshipConfig -NoNewline

        # Append [os] and [os.symbols] sections
        $osBlock = @"

[os]
disabled = false
format = '[ `$symbol ](bg:#a3aed2 fg:#090c0c)'

[os.symbols]
Alpaquita = "🔔"
Alpine = ""
AlmaLinux = "💠"
Amazon = ""
Android = ""
AOSC = "💠"
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
DragonFly = "🐉"
Emscripten = "🔗"
EndeavourOS = "🚀"
Fedora = "󰣛"
FreeBSD = ""
Garuda = "🦅"
Gentoo = "󰣨"
HardenedBSD = "🛡️"
Illumos = "🐦"
Kali = "🐉"
Linux = "󰌽"
Mabox = "📦"
Macos = "󰀵"
Manjaro = ""
Mariner = "🌊"
MidnightBSD = "🌘"
Mint = "󰣭"
NetBSD = "🚩"
NixOS = "❄️"
OpenBSD = "🐡"
OpenCloudOS = "☁️"
openEuler = "🦉"
openSUSE = ""
OracleLinux = "🦴"
Pop = ""
Raspbian = "󰐿"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"
RockyLinux = "💠"
Redox = "🧪"
Solus = "⛵"
SUSE = ""
Ubuntu = "󰕈"
Ultramarine = "🔷"
Unknown = "❓"
Void = ""
Windows = ""
"@
        Add-Content -Path $StarshipConfig -Value $osBlock
        Write-Host "Replaced hardcoded icon with `$os module and platform icons."
    }

    "pastel-powerline" {
        # Enable the [os] module
        (Get-Content $StarshipConfig -Raw) -replace '(?m)(^\[os\]\s*\n.*?)disabled = true', '$1disabled = false' |
            Set-Content $StarshipConfig -NoNewline

        # Append os.symbols block
        $symbols = @"

[os.symbols]
Alpaquita = "🔔"
Alpine = ""
AlmaLinux = "💠"
Amazon = ""
Android = ""
AOSC = "💠"
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
DragonFly = "🐉"
Emscripten = "🔗"
EndeavourOS = "🚀"
Fedora = "󰣛"
FreeBSD = ""
Garuda = "🦅"
Gentoo = "󰣨"
HardenedBSD = "🛡️"
Illumos = "🐦"
Kali = "🐉"
Linux = "󰌽"
Mabox = "📦"
Macos = "󰀵"
Manjaro = ""
Mariner = "🌊"
MidnightBSD = "🌘"
Mint = "󰣭"
NetBSD = "🚩"
NixOS = "❄️"
OpenBSD = "🐡"
OpenCloudOS = "☁️"
openEuler = "🦉"
openSUSE = ""
OracleLinux = "🦴"
Pop = ""
Raspbian = "󰐿"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"
RockyLinux = "💠"
Redox = "🧪"
Solus = "⛵"
SUSE = ""
Ubuntu = "󰕈"
Ultramarine = "🔷"
Unknown = "❓"
Void = ""
Windows = ""
"@
        Add-Content -Path $StarshipConfig -Value $symbols
        Write-Host "Enabled OS detection with platform icons."
    }
}

Write-Host ""
Write-Host "Starship config written to $StarshipConfig"
Write-Host "Restart your shell to see the new prompt."
