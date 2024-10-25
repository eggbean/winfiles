# Ensure the script is run with administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-Not $isAdmin) {
    Write-Error "This script needs to be run as Administrator."
    exit 1
}

# Enable the 'Windows Subsystem for Linux' feature
Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Windows-Subsystem-Linux' | Out-Null

# Enable the 'Virtual Machine Platform' feature (required for WSL2)
Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'VirtualMachinePlatform' | Out-Null

# Set WSL2 as the default version
Write-Host "Setting WSL2 as the default version..." -ForegroundColor Green
wsl --set-default-version 2 > $null 2>&1

# Install WSL kernel update
Write-Host "Checking for WSL kernel update..." -ForegroundColor Green
Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile "$env:TEMP\wsl_update_x64.msi"
Start-Process msiexec.exe -ArgumentList '/i', "$env:TEMP\wsl_update_x64.msi", '/passive', '/norestart' -Wait

# Make a scheduled task to update WSL on next reboot
$wslUpdateAction = New-ScheduledTaskAction -Execute "wsl" -Argument "--update"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopOnIdleEnd -DeleteExpiredTaskAfter 1
Register-ScheduledTask -Action $wslUpdateAction -Trigger $trigger -Settings $settings -TaskName "WSL Update" -Description "Updates WSL on next reboot" -RunLevel Highest -User "NT AUTHORITY\SYSTEM"

# Suggest user to install a Linux distribution from the Microsoft Store
Write-Host "Installation complete! Please go to the Microsoft Store to install your preferred Linux distribution." -ForegroundColor Yellow
Write-Host "You can find Linux distributions here: https://aka.ms/wslstore" -ForegroundColor Cyan

# Remind user that the system needs to be restarted
Write-Host "A system restart is required for changes to take effect." -ForegroundColor Yellow
