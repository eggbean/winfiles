# Installs the wedge redirector for the Chrometana Pro Chrome extension
# https://github.com/MarcGuiselin/wedge
# https://github.com/MarcGuiselin/chrometana-pro
$wedgeDownloadPath = Join-Path $env:TEMP "wedge-download"
if (Test-Path -Path $wedgeDownloadPath) {
    Remove-Item -Path $wedgeDownloadPath -Recurse -Force
}
New-Item -ItemType Directory -Path $wedgeDownloadPath | Out-Null
Push-Location -Path $wedgeDownloadPath
$uri = "https://github.com/MarcGuiselin/wedge/releases/latest/download/installer.exe"
Invoke-WebRequest -Uri $uri -OutFile installer.exe
./installer.exe -quiet
Pop-Location
