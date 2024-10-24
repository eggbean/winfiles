# Module: Set-SoundScheme.psm1

# Global variable to store the sound scheme name
$global:soundSchemeName = $null

# Global hashtable to store event-to-sound mappings
$global:customSounds = @{}

# Function to set a sound for a particular system event
function Set-Sound {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet('Close', 'Minimize', 'Maximize', 'Open', 'SystemNotification', 'Default')]
        [string]$Event,

        [Parameter(Mandatory=$true)]
        [string]$SoundFilePath
    )

    # Define the registry key paths for the system events
    $eventPaths = @{
        'Close'              = 'AppEvents\Schemes\Apps\.Default\Close\.Current'
        'Minimize'           = 'AppEvents\Schemes\Apps\.Default\Minimize\.Current'
        'Maximize'           = 'AppEvents\Schemes\Apps\.Default\Maximize\.Current'
        'Open'               = 'AppEvents\Schemes\Apps\.Default\Open\.Current'
        'SystemNotification' = 'AppEvents\Schemes\Apps\.Default\SystemNotification\.Current'
        'Default'            = 'AppEvents\Schemes\Apps\.Default\.Default\.Current'
    }

    # Ensure the sound file exists
    if (-not (Test-Path -Path $SoundFilePath)) {
        throw "Sound file '$SoundFilePath' does not exist."
    }

    # Add the sound file to the appropriate event
    $global:customSounds[$eventPaths[$Event]] = $SoundFilePath
}

# Function to apply the sound scheme and update the registry
function Set-SoundScheme {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SchemeName
    )

    # Check if a scheme name is provided
    if (-not $SchemeName) {
        throw "You must provide a scheme name using the variable '$soundSchemeName'."
    }
    # Create a new sound scheme under the 'Apps' key
    New-Item -Path "HKCU:\AppEvents\Schemes\Apps\.Default" -Name $SchemeName -Force

    # Assign custom sound files to each event
    foreach ($eventPath in $global:customSounds.Keys) {
        Set-ItemProperty -Path "HKCU:\$eventPath" -Name '(Default)' -Value $global:customSounds[$eventPath]
    }

    # Set the current sound scheme in the registry
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name '(Default)' -Value $SchemeName

    Write-Host "Custom sound scheme '$SchemeName' has been applied!"
}
