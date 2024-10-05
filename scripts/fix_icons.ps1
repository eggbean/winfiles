function Set-FolderIcons {
    # Check if the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Not admin/elevated"
        exit 1
    }

    # Set icons for Adobe Creative Cloud Sync if it exists
    if (Test-Path "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync") {
        Push-Location "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync"
        Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\cloud_fld_w10.ico" .
        Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\cloud_fld_w10_offline.ico" .
        Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\shared_fld_w10.ico" .
        Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\RO_shared_fld_w10.ico" .
        Pop-Location
    }

    # Helper function to set folder icons
    function Set-FolderIcon {
        param (
            [string]$FolderPath,
            [string]$IconPath,
            [string]$InfoTip = "",
            [string]$LocalizedResourceName = ""
        )
        if (Test-Path $FolderPath) {
            Push-Location $FolderPath
            Remove-Item "desktop.ini" -Force -ErrorAction SilentlyContinue
            Add-Content "desktop.ini" "[.ShellClassInfo]"
            if ($LocalizedResourceName) {
                Add-Content "desktop.ini" "LocalizedResourceName=$LocalizedResourceName"
            }
            if ($InfoTip) {
                Add-Content "desktop.ini" "InfoTip=$InfoTip"
            }
            Add-Content "desktop.ini" "IconResource=$IconPath,0"
            Set-ItemProperty "desktop.ini" -Name Attributes -Value ([System.IO.FileAttributes]::Hidden + [System.IO.FileAttributes]::System + [System.IO.FileAttributes]::Archive)
            Set-ItemProperty "." -Name Attributes -Value ([System.IO.FileAttributes]::ReadOnly)
            Pop-Location
        }
    }

    # Set icons for various folders
    Set-FolderIcon "$env:USERPROFILE\winfiles" "$env:USERPROFILE\winfiles\icons\my_icons\microsoft_windows_11.ico"
    Set-FolderIcon "$env:USERPROFILE\My Drive" "$env:USERPROFILE\winfiles\icons\my_icons\google_drive.ico" "Your Google Drive folder contains files that you're syncing with Google."
    Set-FolderIcon "$env:USERPROFILE\iCloudDrive" "$env:USERPROFILE\winfiles\icons\my_icons\iCloud Folder.ico" "iCloud Drive" "iCloud Drive"
    Set-FolderIcon "$env:USERPROFILE\winfiles\bin" "$env:USERPROFILE\winfiles\icons\my_icons\bat.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\Clink" "$env:USERPROFILE\winfiles\icons\my_icons\Batch Folder Icon.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\fonts" "$env:USERPROFILE\winfiles\icons\my_icons\fonts.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\icons" "$env:USERPROFILE\winfiles\icons\my_icons\Apps Folder.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\icons\my_icons" "$env:USERPROFILE\winfiles\icons\my_icons\Apps Folder.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\reg" "$env:USERPROFILE\winfiles\icons\my_icons\Registry Folder Icon.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\scripts" "$env:USERPROFILE\winfiles\icons\my_icons\VBS Folder.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\Settings" "$env:USERPROFILE\winfiles\icons\my_icons\Batch Folder Icon.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\SylphyHorn" "$env:USERPROFILE\winfiles\icons\my_icons\Batch Folder Icon.ico"
    Set-FolderIcon "$env:USERPROFILE\winfiles\Windows_Terminal" "$env:USERPROFILE\winfiles\icons\my_icons\terminal.ico"
}

# Call the function to execute the logic
Set-FolderIcons
