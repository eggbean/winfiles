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

    if ($Message -ne "") {
        Write-Host "$Message" -ForegroundColor Yellow
    }

    while ($true) {

        $elapsedTime = (Get-Date) - $startTime
        $remainingTime = $WaitTime - [int]$elapsedTime.TotalSeconds

        if ($ShowCountdown) {
            Write-Host -NoNewline "`rWaiting for $remainingTime seconds. Press any key to cancel..." -ForegroundColor Yellow
        }

        if ($Host.UI.RawUI.KeyAvailable) {
            break
        }

        if ($remainingTime -le 0) {
            break
        }

        # Throttle the loop to avoid high CPU usage
        Start-Sleep -Milliseconds 200
    }
}
