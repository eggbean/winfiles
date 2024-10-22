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
$selectedProfileName = $profileOptions | gum choose --cursor.foreground="#FF5733" --height=10 --cursor="•"

# Check if a profile was selected
if (-Not $selectedProfileName) {
    Write-Error "No profile was selected. Exiting."
    exit 1
}

# Find the selected profile by name
$selectedProfile = $profiles | Where-Object { $_.name -eq $selectedProfileName }

if (-Not $selectedProfile) {
    Write-Error "Selected profile not found. Exiting."
    exit 1
}

# Get the GUID of the selected profile
$selectedGUID = $selectedProfile.guid

# Set the GUID into the HKCU environment variable
Set-ItemProperty -Path "HKCU:\Environment" -Name "WT_DEFAULT_SHELL" -Value $selectedGUID

# Inform the user
Write-Output "The default Windows Terminal shell has been set to: $selectedProfileName (GUID: $selectedGUID)"
Write-Output "To apply the change, you may need to restart your terminal."
