# Function to create a Start Menu shortcut
function Set-StartMenuShortcut {
    param (
        [string]$Subdir,       # Folder under Start Menu Programs
        [string]$Name,         # Name of the shortcut
        [string]$Target        # Target executable or file for the shortcut
    )

    # Define paths
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$Subdir"
    $shortcutPath = "$startMenuPath\$Name.lnk"

    # Check if the subdirectory exists; if not, create it
    if (-not (Test-Path -Path $startMenuPath)) {
        New-Item -Path $startMenuPath -ItemType Directory
    }

    # Check if the shortcut already exists
    if (-not (Test-Path -Path $shortcutPath)) {
        try {
            # Create the shortcut
            $WScriptShell = New-Object -ComObject WScript.Shell
            $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $Target
            $shortcut.Save()

            Write-Output "$Name startup shortcut created."
        }
        catch {
            Write-Error "Failed to create shortcut for '$Name'. Error: $_"
        }
    }
    else {
        Write-Output "Shortcut for '$Name' already exists."
    }
}
