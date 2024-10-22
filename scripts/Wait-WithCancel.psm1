# Example usage:
# Wait-WithCancel -WaitTime 15 -Message "Custom wait message" -ShowCountdown
# Wait-WithCancel -WaitTime 15 -Message "Custom wait message"
# Wait-WithCancel -WaitTime 15 -ShowCountdown
# Wait-WithCancel -WaitTime 15
# Wait-WithCancel

function Wait-WithCancel {
    param (
        [int]$WaitTime = 10,            # Wait time in seconds
        [string]$Message = "",          # Custom message to show (if provided)
        [switch]$ShowCountdown          # Countdown switch (used without message)
    )

    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($WaitTime)
    $cancelled = $false

    # Display the message if provided
    if ($Message -ne "") {
        Write-Host "$Message" -ForegroundColor Yellow
    }

    # Clear any pending key presses
    while ($Host.UI.RawUI.KeyAvailable) {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    while ($true) {
        $currentTime = Get-Date
        $remainingTime = [math]::Max([int]($endTime - $currentTime).TotalSeconds, 0)

        # Show countdown if the switch is enabled
        if ($ShowCountdown) {
            # Clear the entire line before writing new content
            Write-Host "`r$(' ' * 80)" -NoNewline
            Write-Host "`rWaiting for $remainingTime seconds. Press any key to cancel..." -NoNewline -ForegroundColor Yellow
        }

        # Check if the user has pressed a key (to cancel)
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $cancelled = $true
            break
        }

        # Exit if the time is up
        if ($remainingTime -le 0) {
            break
        }

        # Throttle the loop to avoid high CPU usage
        Start-Sleep -Milliseconds 100
    }

    # If the countdown was shown, clear the line and move to next line
    if ($ShowCountdown) {
        Write-Host "`r$(' ' * 80)" -NoNewline  # Clear the line
        Write-Host "`r"  # Move to next line
    }

    # Return whether the wait was cancelled
    return !$cancelled
}
