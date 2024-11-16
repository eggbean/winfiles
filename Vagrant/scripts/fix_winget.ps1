# Fix winget --source winget on Vagrant boxes from gusztavvargadr
# [ELEVATED]
try {
    # Download UI.Xaml
    $xamlPath = ".\Microsoft.UI.Xaml.2.8.x64.appx"
    Start-BitsTransfer -Source "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" -Destination $xamlPath
    Write-Host "Downloaded Microsoft.UI.Xaml"

    # Install UI.Xaml
    Add-AppxPackage -Path $xamlPath
    Write-Host "Installed Microsoft.UI.Xaml"

    # Download Winget Installer
    $wingetPath = ".\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Start-BitsTransfer -Source "https://github.com/microsoft/winget-cli/releases/download/v1.9.2411-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Destination $wingetPath
    Write-Host "Downloaded Winget Installer"

    # Install Winget
    Add-AppxPackage -Path $wingetPath
    Write-Host "Installed Winget"
} catch {
    Write-Error "Error during Winget setup: $_"
}
