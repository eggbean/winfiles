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

    while ($true) {
        $remainingTime = [math]::Max([int]($endTime - (Get-Date)).TotalSeconds, 0)

        # Show countdown if the switch is enabled
        if ($ShowCountdown) {
            Write-Host -NoNewline "`rWaiting for $remainingTime seconds. Press any key to cancel..." -ForegroundColor Yellow
        }

        # Check if the user has pressed a key (to cancel)
        if ($Host.UI.RawUI.KeyAvailable) {
            # Consume the key press
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $cancelled = $true
            break
        }

        # Exit if the time is up
        if ($remainingTime -le 0) {
            break
        }

        # Throttle the loop to avoid high CPU usage
        Start-Sleep -Milliseconds 200
    }

    # If the countdown was shown, clear the last message
    if ($ShowCountdown) {
        Write-Host "`r`n"
    }

    # Return whether the wait was cancelled
    return !$cancelled
}
