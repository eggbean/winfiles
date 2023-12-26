# Work-in-progress. Currently just a translation by ChatGPT,
# which doesn't work.

# Requires -RunAsAdministrator

# Clones Linux dotfiles repository and makes relevant symlinks to AppData
# Sets symlinks in AppData for clink settings and dotfiles in this repository
# Hides dotfiles and dotdirectories in $env:USERPROFILE and winfiles
# Installs and registers fonts in font directory

# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Not admin/elevated"
    exit 1
}

# Import GITHUB_ACCESS_TOKEN
. "$PSScriptRoot\GITHUB_ACCESS_TOKEN.ps1"

# Sparse checkout dotfiles
$userProfileDotfiles = Join-Path $env:USERPROFILE ".dotfiles"
if (-not (Test-Path $userProfileDotfiles)) {
    Set-Location $env:USERPROFILE
    git clone --no-checkout --depth=1 --filter=tree:0 "https://$env:GITHUB_ACCESS_TOKEN@github.com/eggbean/.dotfiles.git"
}
Set-Location $userProfileDotfiles
git sparse-checkout set --no-cone /.gitattributes .git-crypt bin/scripts config
git checkout

# Function to handle symlinking
function Create-Symlink {
    param (
        [string]$Source,
        [string]$Destination
    )
    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source
}

# Symlink configurations
Create-Symlink "$userProfileDotfiles\config\.gnupg" "$env:APPDATA\gnupg"
Create-Symlink "$userProfileDotfiles\config\.config\copyq" "$env:APPDATA\copyq"
Create-Symlink "$userProfileDotfiles\config\.config\gh" "$env:APPDATA\`"GitHub CLI`""
Create-Symlink "$userProfileDotfiles\config\.config\mpv" "$env:APPDATA\mpv"
Create-Symlink "$userProfileDotfiles\config\.config\qutebrowser" "$env:APPDATA\qutebrowser\config"
Create-Symlink "$userProfileDotfiles\config\.config\vim" "$env:USERPROFILE\vimfiles"

# Setup Clink
$localAppDataClink = Join-Path $env:LOCALAPPDATA "clink"
if (-not (Test-Path $localAppDataClink)) {
    New-Item -ItemType Directory -Path $localAppDataClink
}
Create-Symlink "$env:USERPROFILE\winfiles\scripts\clink_start.cmd" "$localAppDataClink\clink_start.cmd"
Create-Symlink "$env:USERPROFILE\winfiles\Settings\clink_settings" "$localAppDataClink\clink_settings"
Create-Symlink "$env:USERPROFILE\winfiles\Settings\_inputrc" "$localAppDataClink\_inputrc"

if (-not (Test-Path $env:CLINK_COMPLETIONS_DIR)) {
    git clone https://github.com/vladimir-kotikov/clink-completions.git "$env:USERPROFILE\winfiles\Settings\clink-completions"
}

# Copy any existing config files to repository
$userProfileConfig = Join-Path $env:USERPROFILE ".config"
if (Test-Path $userProfileConfig) {
    robocopy $userProfileConfig "$env:USERPROFILE\winfiles\Settings\.config" /move /e /it /im >$null
    Remove-Item $userProfileConfig -Recurse -Force
}
Create-Symlink "$env:USERPROFILE\winfiles\Settings\.config" $userProfileConfig
Set-ItemProperty -LiteralPath $userProfileConfig -Name Attributes -Value 'Hidden'

# Symlink ~/.profile and ~/.envrc
Create-Symlink "$env:USERPROFILE\winfiles\Settings\.profile" "$env:USERPROFILE\.profile"
Set-ItemProperty -LiteralPath "$env:USERPROFILE\.profile" -Name Attributes -Value 'Hidden'
Create-Symlink "$env:USERPROFILE\winfiles\Settings\.envrc" "$env:USERPROFILE\.envrc"
Set-ItemProperty -LiteralPath "$env:USERPROFILE\.envrc" -Name Attributes -Value 'Hidden'

# Hide dotfiles and dotdirectories in $env:USERPROFILE and winfiles
Get-ChildItem "$env:USERPROFILE\.*" -Force | Where-Object { -not $_.Attributes.ToString().Contains("Hidden") } | ForEach-Object { $_.Attributes += 'Hidden' }
Get-ChildItem "$env:USERPROFILE\winfiles\.*" -Force | Where-Object { -not $_.Attributes.ToString().Contains("Hidden") } | ForEach-Object { $_.Attributes += 'Hidden' }

# Install fonts
Push-Location "$env:USERPROFILE\winfiles\fonts"
Get-ChildItem -Directory | ForEach-Object {
    Push-Location $_.FullName
    & "$env:USERPROFILE\winfiles\bin\fontreg" /copy
    Pop-Location
}
Pop-Location

# Symlink SumatraPDF config
$sumatraPDFPath = Join-Path $env:LOCALAPPDATA "SumatraPDF"
if (-not (Test-Path $sumatraPDFPath)) {
    New-Item -ItemType Directory -Path $sumatraPDFPath
    Copy-Item "$env:USERPROFILE\winfiles\Settings\SumatraPDF-settings.txt" $sumatraPDFPath
}

# Symlink Windows Terminal config
$windowsTerminalPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (-not (Test-Path $windowsTerminalPath)) {
    New-Item -ItemType Directory -Path $windowsTerminalPath
}
Create-Symlink "$env:USERPROFILE\winfiles\Windows_Terminal\settings.json" "$windowsTerminalPath\settings.json"
