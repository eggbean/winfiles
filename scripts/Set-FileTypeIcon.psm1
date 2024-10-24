function Set-FileTypeIcon {
    param(
        [string]$Extension,  # File extension (e.g., ".txt")
        [string]$IconPath    # Path to the icon file
    )

    # Define the registry path for the file extension under HKEY_CURRENT_USER
    $regPath = "HKCU:\Software\Classes\$Extension\DefaultIcon"

    # Check if the icon file exists
    if (-not (Test-Path $IconPath)) {
        Write-Error "Icon file not found: $IconPath"
        return
    }

    # Create or set the registry key for the file extension
    try {
        # Create the registry key if it doesn't exist, suppress output
        if (-not (Test-Path $regPath)) {
            New-Item -Path "HKCU:\Software\Classes\$Extension" -Force | Out-Null
            New-Item -Path $regPath -Force | Out-Null
        }

        # Set the default value (empty name for default) in the DefaultIcon registry key, suppress output
        New-ItemProperty -Path $regPath -Name '(Default)' -Value $IconPath -Force | Out-Null

        Write-Host "Icon set successfully for file type: $Extension"
    } catch {
        Write-Error "Failed to set the icon. Error: $_"
    }
}
