function Set-FolderIcon {
    param (
        [string]$FolderPath,
        [string]$IconPath,
        [string]$InfoTip = "",
        [string]$LocalizedResourceName = "",
        [switch]$Create
    )

    if (-not (Test-Path $FolderPath)) {
        if ($Create) {
            try {
                New-Item -Path $FolderPath -ItemType Directory -Force
                Write-Host "Folder '$FolderPath' created."
            }
            catch {
                Write-Error "Failed to create folder '$FolderPath'. Error: $_"
                return
            }
        }
        else {
            Write-Host "Folder '$FolderPath' does not exist. Skipping."
            return
        }
    }

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
