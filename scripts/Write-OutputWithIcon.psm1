function Write-OutputWithIcon {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message,

        [ValidateSet("info", "working", "success", "warning", "error")]
        [string]$IconType = "info"
    )

    # Define icons based on IconType
    $icon = switch ($IconType) {
        "info"    { [char]::ConvertFromUtf32(0x2139) }  # Info       ℹ️
        "working" { [char]::ConvertFromUtf32(0x26CF) }  # Pick       ⛏
        "success" { [char]::ConvertFromUtf32(0x2705) }  # Check mark ✅
        "warning" { [char]::ConvertFromUtf32(0x26A0) }  # Warning    ⚠️
        "error"   { [char]::ConvertFromUtf32(0x274C) }  # Cross      ❌
    }

    # Send the message with the icon to the output stream
    Write-Output "$icon $Message"
}

# Example usage:
# Write-OutputWithIcon -Message "Operation completed successfully." -IconType "success"
# Write-OutputWithIcon -Message "This is a warning message." -IconType "warning"
# Write-OutputWithIcon -Message "An error occurred." -IconType "error"
