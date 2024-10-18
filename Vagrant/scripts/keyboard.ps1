# Set British keyboard
try {
    Set-WinUserLanguageList -LanguageList "en-GB" -Force
    Write-Host "Set British keyboard layout"
} catch {
    Write-Error "Error setting keyboard layout: $_"
}
