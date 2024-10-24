# Function to set the filetype icon for a specific file extension

function Set-FileTypeIcon {
    param(
        [string]$Extension,  # File extension
        [string]$IconPath    # Path to the icon file
    )

    # Define the registry path for the file extension
    $regPath = "HKCR\$Extension\DefaultIcon"

    # Check if the icon file exists
    if (-not (Test-Path $IconPath)) {
        Write-Error "Icon file not found: $IconPath"
        return
    }

    # Create or set the registry key for the file extension
    try {
        # Create the registry key if it doesn't exist
        if (-not (Test-Path $regPath)) {
            New-Item -Path "HKCR:\$Extension" -Force
            New-Item -Path $regPath -Force
        }

        # Set the default icon path in the DefaultIcon registry entry
        Set-ItemProperty -Path $regPath -Name '' -Value $IconPath

        Write-Host "Icon set successfully for file type: $Extension"
    } catch {
        Write-Error "Failed to set the icon. Error: $_"
    }
}
