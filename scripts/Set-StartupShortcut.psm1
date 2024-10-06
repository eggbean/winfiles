function Set-StartupShortcut {
    param (
        [string]$Name,             # Name of the shortcut
        [string]$TargetPath,       # Target application executable
        [string]$Arguments = "",   # Arguments for the executable (optional)
        [string]$IconPath = "",    # Path to the icon file (optional)
        [string]$StartIn = "",     # Starting directory (optional)
        [string]$WindowStyle = "1" # Window style: 1 - Normal, 3 - Maximized, 7 - Minimized (optional)
    )

    # Define the shortcut path in the Startup folder
    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$Name.lnk"

    # Check if the shortcut already exists
    if (-Not (Test-Path $shortcutPath)) {
        try {
            # Create WScript.Shell COM object
            $WshShell = New-Object -ComObject WScript.Shell

            # Create a new shortcut
            $shortcut = $WshShell.CreateShortcut($shortcutPath)

            # Set properties for the shortcut
            $shortcut.TargetPath = $TargetPath
            $shortcut.Arguments = $Arguments

            if ($IconPath -ne "") {
                $shortcut.IconLocation = $IconPath
            }

            if ($StartIn -ne "") {
                $shortcut.WorkingDirectory = $StartIn
            }

            # Set the window style (normal, minimized, maximized)
            $shortcut.WindowStyle = [int]$WindowStyle

            # Save the shortcut
            $shortcut.Save()

            Write-Output "$Name startup shortcut created successfully."

        } catch {
            Write-Error "Failed to create shortcut for $Name. Error: $_"
        }
    } else {
        Write-Output "$Name shortcut already exists. Skipping creation."
    }
}
