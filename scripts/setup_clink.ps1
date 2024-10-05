# Setup Clink, cloning relevant repositores for extra features

Set-ItemProperty -Path "HKCU:\Environment" -Name "CLINK_PATH"            -Value "$env:USERPROFILE\winfiles\Clink\clink-path"
Set-ItemProperty -Path "HKCU:\Environment" -Name "CLINK_COMPLETIONS_DIR" -Value "$env:USERPROFILE\winfiles\Clink\clink-completions\completions"

if (-Not (Test-Path "$env:LOCALAPPDATA\clink")) {
    New-Item -Path "$env:LOCALAPPDATA\clink" -ItemType Directory
}

Set-Symlink "$env:LOCALAPPDATA\clink\clink_start.cmd" "$env:USERPROFILE\winfiles\Clink\clink_start.cmd"
Set-Symlink "$env:LOCALAPPDATA\clink\clink_settings"  "$env:USERPROFILE\winfiles\Clink\clink_settings"
Set-Symlink "$env:LOCALAPPDATA\clink\_inputrc"        "$env:USERPROFILE\winfiles\Clink\_inputrc"

$clinkCompDir = "$env:USERPROFILE\winfiles\Clink\clink-completions\completions"
$clinkGizmosDir = "$env:USERPROFILE\winfiles\Clink\clink-gizmos"

if (-Not (Test-Path $clinkCompDir)) {
    git clone https://github.com/vladimir-kotikov/clink-completions.git $clinkCompDir
    & "C:\Program Files (x86)\clink\clink_x64.exe" installscripts $clinkCompDir
}

if (-Not (Test-Path $clinkGizmosDir)) {
    git clone https://github.com/chrisant996/clink-gizmos.git $clinkGizmosDir
    & "C:\Program Files (x86)\clink\clink_x64.exe" installscripts $clinkGizmosDir
}

# Set Clink to autorun for all users
Start-Process -FilePath "cmd.exe" -ArgumentList "/c clink autorun -a install >NUL 2>&1" -NoNewWindow -Wait

# If this script was run as admin, ownership must be taken
# afterwards as in the bootstrap script that initiated this one.
