param (
    [string]$time_zone,
    [string]$language
)

try {
    # Set the time zone to the same as the host computer's
    Write-Host "Setting the time zone to $time_zone"
    tzutil /s $time_zone
} catch {
    Write-Error "Error setting the time zone: $_"
}

try {
    # Change the language to the same as the host computer's
    Write-Host "Setting the language to $language"
    Set-WinUserLanguageList -LanguageList $language -Force
} catch {
    Write-Error "Error setting the language: $_"
}
