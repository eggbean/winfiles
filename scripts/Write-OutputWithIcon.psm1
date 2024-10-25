function Write-OutputWithIcon {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message,

        [ValidateSet("info", "success", "warning", "error")]
        [string]$IconType = "info"
    )

    # Define icons based on IconType
    $icon = switch ($IconType) {
        "success" { "✔️" }
        "warning" { "⚠️" }
        "error"   { "❌" }
        default   { "ℹ️" }
    }

    # Send the message with the icon to the output stream
    Write-Output "$icon $Message"
}

# Example usage:
# Write-OutputWithIcon -Message "Operation completed successfully." -IconType "success"
# Write-OutputWithIcon -Message "This is a warning message." -IconType "warning"
# Write-OutputWithIcon -Message "An error occurred." -IconType "error"
