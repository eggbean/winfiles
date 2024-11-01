# Select from Windows Terminal profiles to set the default shell

# Set the path to Windows Terminal's settings.json file
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Check if the settings file exists
if (-Not (Test-Path $settingsPath)) {
    Write-Error "Windows Terminal settings file not found at: $settingsPath"
    exit 1
}

# Read the settings.json content
$settingsJson = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

# Extract profiles
$profiles = $settingsJson.profiles.list

# Prepare a list of profile names for Gum selection
$profileOptions = foreach ($profile in $profiles) {
    "$($profile.name)"
}

# Pipe the profile options into the gum command
$selectedProfileName = $profileOptions | gum choose --header="Choose default shell:" --selected.foreground="White" --height=10

# Find the selected profile by name
$selectedProfile = $profiles | Where-Object { $_.name -eq $selectedProfileName }

# Get the GUID of the selected profile
$selectedGUID = $selectedProfile.guid

# Set the GUID into the HKCU environment variable
Set-ItemProperty -Path "HKCU:\Environment" -Name "WT_DEFAULT_SHELL" -Value $selectedGUID

# Trigger post-checkout git hook to update Windows Terminal configuration
[Console]::ForegroundColor = 'DarkYellow'
Write-Output "Setting Windows Terminal default shell to: $selectedProfileName (GUID: $selectedGUID)"
git checkout "$PSScriptRoot\..\.githooks\post-checkout" >nul 2>nul
Write-Output "To apply the change, you may need to restart your terminal."
[Console]::ResetColor()
