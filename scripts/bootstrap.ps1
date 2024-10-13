# Check if the script is running with admin privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-Not $isAdmin) {
    Write-Error "This script needs to be run as admin/elevated."
    exit 1
}

# Check command line arguments
$SkipPackages = $false
if ($args.Count -gt 0 -and $args[0] -eq "--skip-packages") {
    $SkipPackages = $true
}

# Import modules
Import-Module -Name "$PSScriptRoot\Set-FolderIcon.psm1"
Import-Module -Name "$PSScriptRoot\Set-StartMenuShortcut.psm1"
Import-Module -Name "$PSScriptRoot\Set-StartupShortcut.psm1"
Import-Module -Name "$PSScriptRoot\Set-Symlink.psm1"
Import-Module -Name "$PSScriptRoot\Unlock-Repository.psm1"

# Exclude known false positives from Windows Defender scanning
& "$PSScriptRoot\defender_whitelist.ps1"

# Install packages using winget
if (-Not $SkipPackages) {
    if (-Not $env:bootstrapped) {
        # Uninstall Git so that it can be
        # reinstalled with my specified options
        winget uninstall -e --id Git.Git
    }
    & "$PSScriptRoot\install_packages.ps1"
}

# Fix missing StartMenu Shortcuts if packages were installed using another account
if ($env:USERNAME -ne "jason" -and $env:USERNAME -ne "vagrant") {
    Set-StartMenuShortcut -Subdir "WinDirStat" -Name "WinDirStat" -Target "$env:ProgramFiles(x86)\WinDirStat\windirstat.exe"
    Set-StartMenuShortcut -Subdir "WinDirStat" -Name "Help (ENG)" -Target "$env:ProgramFiles(x86)\WinDirStat\windirstat.chm"
}

# Add vim to $PATH
& "$PSScriptRoot\add_vim_to_path.ps1"

# Install scoop for multi-users and packages (if not already installed)
if (-Not $env:bootstrapped) {
    & "$PSScriptRoot\install_scoop.ps1"
}

# Install the wedge redirector for the Chrometana Pro Chrome extension
if (-Not $env:bootstrapped) {
    & "$PSScriptRoot\install_wedge.ps1"
}

# Setup Clink
& "$PSScriptRoot\setup_clink.ps1"

# Take ownership of winfiles
$winfilesPath = "$env:USERPROFILE\winfiles"
$acl = Get-Acl $winfilesPath
$owner = [System.Security.Principal.NTAccount] "$env:USERNAME"
$acl.SetOwner($owner)
try {
    Set-Acl $winfilesPath $acl
    echo ":white_check_mark: Taken ownership of winfiles" | gum format -t emoji
} catch {
    echo ":warning: Error taking ownership of winfiles: $_" | gum format -t emoji
    exit 1
}

# Sparse checkout Linux .dotfiles repository
$dotfilesPath = "$env:USERPROFILE\.dotfiles"
if (-Not (Test-Path $dotfilesPath)) {
    Push-Location -Path $env:USERPROFILE
    git clone --no-checkout --depth=1 --filter=tree:0 https://github.com/eggbean/.dotfiles.git
    Set-Location -Path $dotfilesPath
    git sparse-checkout set --no-cone /.gitattributes .git-crypt .githooks bin/scripts config
    git checkout
    $acl = Get-Acl $dotfilesPath
    $owner = [System.Security.Principal.NTAccount] "$env:USERNAME"
    $acl.SetOwner($owner)
    try {
        Set-Acl $dotfilesPath $acl
        Write-Output "Taken ownership of .dotfiles"
    } catch {
        Write-Error "Error taking ownership of .dotfiles: $_"
        exit 1
    }
    Pop-Location
}

# Create symlinks between $APPDATA and Linux dotfiles
Set-Symlink "$env:APPDATA\GitHub CLI"                "$env:USERPROFILE\.dotfiles\config\.config\gh"
Set-Symlink "$env:APPDATA\XnViewMP"                  "$env:USERPROFILE\.dotfiles\config\.config\XnViewMP"
Set-Symlink "$env:APPDATA\copyq"                     "$env:USERPROFILE\.dotfiles\config\.config\copyq"
Set-Symlink "$env:APPDATA\geoipupdate"               "$env:USERPROFILE\.dotfiles\config\.config\geoipupdate"
Set-Symlink "$env:APPDATA\gnupg"                     "$env:USERPROFILE\.dotfiles\config\.gnupg"
Set-Symlink "$env:APPDATA\mpv"                       "$env:USERPROFILE\.dotfiles\config\.config\mpv"
Set-Symlink "$env:APPDATA\qutebrowser\config"        "$env:USERPROFILE\.dotfiles\config\.config\qutebrowser"
Set-Symlink "$env:APPDATA\tlrc"                      "$env:USERPROFILE\.dotfiles\config\.config\tlrc"
Set-Symlink "$env:LOCALAPPDATA\glow\Config\glow.yml" "$env:USERPROFILE\.dotfiles\config\.config\glow\glow.yml"

# Create symlink for vimfiles from Linux dotfiles repository and make it hidden
Set-Symlink "$env:USERPROFILE\vimfiles" "$env:USERPROFILE\.dotfiles\config\.config\vim"
(Get-Item "$env:USERPROFILE\vimfiles" -Force).Attributes += 'Hidden'

# Create vimfiles shortcut to make it easily accessible in the GUI
$shortcutPath = "$env:USERPROFILE\vimfiles.lnk"
if (-Not (Test-Path $shortcutPath)) {
    $ws = New-Object -ComObject WScript.Shell
    $shortcut = $ws.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$env:USERPROFILE\.dotfiles\config\.config\vim"
    $shortcut.IconLocation = "$env:USERPROFILE\winfiles\icons\my_icons\vimfiles.ico"
    $shortcut.Save()
    Write-Output "vimfiles shortcut created"
}

# Create symlinks between $APPDATA and this repository
$link = "$env:LOCALAPPDATA\Packages\48914EllipticPhenomena.OnePhotoViewer_8w313s78tpvfc\LocalCache\Local\One Photo Viewer\OnePhotoViewer.config"
$target = "$env:USERPROFILE\winfiles\Settings\AppData\OnePhotoViewer.config"
Set-Symlink $link $target
Set-Symlink "$env:LOCALAPPDATA\Programs\WinSCP\WinSCP.ini" "$env:USERPROFILE\winfiles\Settings\AppData\WinSCP.ini"

# Setup OpenSSH and retrieve SSH key from Dashlane vault
& "$PSScriptRoot\setup_openssh.ps1"
Set-Symlink "$env:USERPROFILE\.ssh" "$env:USERPROFILE\winfiles\Settings\.ssh"
(Get-Item "$env:USERPROFILE\.ssh" -Force).Attributes += 'Hidden'

# Retrieve GPG private key from Dashlane if not present in GPG keyring
& "$PSScriptRoot\get_gpg_key.ps1"
Write-Output y | & "$env:USERPROFILE\winfiles\bin\dcli" logout | Out-Null

# Decrypt repositories if locked
$repos = @("$env:USERPROFILE\winfiles", "$env:USERPROFILE\.dotfiles")
foreach ($repo in $repos) {
    Unlock-Repository $repo
}

# Set environment variables
Set-ItemProperty -Path "HKCU:\Environment" -Name "BROWSER"               -Value "C:\Program Files\qutebrowser\qutebrowser.exe"
Set-ItemProperty -Path "HKCU:\Environment" -Name "EDITOR"                -Value "vim"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GEOIPUPDATE_CONF_FILE" -Value "$env:APPDATA\geoipupdate\GeoIP.conf"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GEOIPUPDATE_LOCK_FILE" -Value "$env:APPDATA\geoipupdate\_geoipupdate.lock"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GH_BROWSER"            -Value "C:\\Program\ Files\\qutebrowser\\qutebrowser.exe"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GNUPGHOME"             -Value "$env:APPDATA\gnupg"
Set-ItemProperty -Path "HKCU:\Environment" -Name "HOME"                  -Value "$env:USERPROFILE"
Set-ItemProperty -Path "HKCU:\Environment" -Name "LESS"                  -Value "-MRQx4F#10"
Set-ItemProperty -Path "HKCU:\Environment" -Name "LESSHISTFILE"          -Value "$env:APPDATA\_lesshst"
Set-ItemProperty -Path "HKCU:\Environment" -Name "RIPGREP_CONFIG_PATH"   -Value "$env:USERPROFILE\.config\ripgrep\ripgreprc"
Set-ItemProperty -Path "HKCU:\Environment" -Name "WGET2RC"               -Value "$env:USERPROFILE\.config\wget\wget2rc"

# Set default distro for Windows Terminal (you can see how this is used in the post-checkout git hook file)
if ($env:USERNAME -eq "jason") {
    Set-ItemProperty -Path "HKCU:\Environment" -Name "DEFAULT_WSL" -Value "{7f586916-8357-53d4-bb2b-ca96f639898a}"   # Pengwin
} elseif ($env:USERNAME -eq "webadmin") {
    Set-ItemProperty -Path "HKCU:\Environment" -Name "DEFAULT_WSL" -Value "{bd3678cb-99b6-41c8-aa3d-98e6e4ada214}"   # Ubuntu
}

# Make lowercase HOSTNAME environment variable as I prefer it sometimes
if (-Not $env:HOSTNAME) {
    $hostname = $env:COMPUTERNAME.ToLower()
    $env:HOSTNAME = $hostname
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "HOSTNAME" -Value $hostname
    Write-Output "HOSTNAME environment variable set to '$hostname'"
}

# Write config file for LocalSend using heredoc
$settingsPath = "$env:APPDATA\LocalSend\settings.json"
$settingsDir = "$env:APPDATA\LocalSend"
if (-Not (Test-Path $settingsPath)) {
    if (-Not (Test-Path $settingsDir)) {
        New-Item -Path $settingsDir -ItemType Directory | Out-Null
    }
    $config = @"
{
  "flutter.ls_color": "localsend",
  "flutter.ls_share_via_link_auto_accept": true,
  "flutter.ls_auto_finish": true,
  "flutter.ls_quick_save": true,
  "flutter.ls_minimize_to_tray": true,
  "flutter.ls_save_window_placement": false,
  "flutter.ls_alias": "$hostname"
}
"@
    $config | Set-Content -Path $settingsPath -Force
}

# Move and symlink .config
$configPath = "$env:USERPROFILE\.config"
$targetPath = "$env:USERPROFILE\winfiles\Settings\.config"
if (Test-Path $configPath -PathType Any) {
    $item = Get-Item $configPath -Force
    if (-Not ($item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint))) {
        robocopy $configPath $targetPath /move /e /it /im > $null
        Remove-Item -Recurse -Force $configPath
        Write-Output "Existing .config directory removed."
    }
    Set-Symlink $configPath $targetPath
    (Get-Item $configPath -Force).Attributes += 'Hidden'
}

# Symlink other dotfiles
$dotfiles = @(".digrc", ".envrc", ".profile")
foreach ($file in $dotfiles) {
    $source = "$env:USERPROFILE\$file"
    $target = "$env:USERPROFILE\winfiles\Settings\$file"
    Set-Symlink $source $target
}

# Create symlink for git config from Linux dotfiles repository
Set-Symlink "$env:USERPROFILE\.config\git" "$env:USERPROFILE\.dotfiles\config\.config\git"
$envName = "GIT_CONFIG_GLOBAL"
$envValue = "$env:USERPROFILE\.config\git\win.config"
Set-ItemProperty -Path "HKCU:\Environment" -Name $envName -Value $envValue
[System.Environment]::SetEnvironmentVariable($envName, $envValue, [System.EnvironmentVariableTarget]::User)

# Set icons for Adobe Creative Cloud Sync if it exists
if (Test-Path "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync") {
    Push-Location "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync"
    Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\cloud_fld_w10.ico" .
    Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\cloud_fld_w10_offline.ico" .
    Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\shared_fld_w10.ico" .
    Copy-Item "$env:USERPROFILE\winfiles\icons\my_icons\RO_shared_fld_w10.ico" .
    Pop-Location
}

# Set icons for various folders
Set-FolderIcon "$env:USERPROFILE\My Drive" "%USERPROFILE%\winfiles\icons\my_icons\google_drive.ico" "Your Google Drive folder contains files that you're syncing with Google."
Set-FolderIcon "$env:USERPROFILE\iCloudDrive" "%USERPROFILE%\winfiles\icons\my_icons\iCloud Folder.ico" "iCloud Drive" "iCloud Drive"
Set-FolderIcon "$env:USERPROFILE\winfiles" "%USERPROFILE%\winfiles\icons\my_icons\microsoft_windows_11.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Clink" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Settings" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\SylphyHorn" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Windows_Terminal" "%USERPROFILE%\winfiles\icons\my_icons\terminal.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\bin" "%USERPROFILE%\winfiles\icons\my_icons\bat.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\fonts" "%USERPROFILE%\winfiles\icons\my_icons\fonts.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\icons" "%USERPROFILE%\winfiles\icons\my_icons\Apps Folder.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\icons\my_icons" "%USERPROFILE%\winfiles\icons\my_icons\Apps Folder.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\reg" "%USERPROFILE%\winfiles\icons\my_icons\Registry Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\scripts" "%USERPROFILE%\winfiles\icons\my_icons\VBS Folder.ico"

# Create startup shortcuts
Set-StartupShortcut -Name "CopyQ" `
                    -TargetPath "C:\Program Files\CopyQ\copyq.exe"

Set-StartupShortcut -Name "Sizer" `
                    -TargetPath "C:\Program Files (x86)\Sizer\sizer.exe"

Set-StartupShortcut -Name "SylphyHorn" `
                    -TargetPath "$env:USERPROFILE\winfiles\SylphyHorn\SylphyHorn.exe"

Set-StartupShortcut -Name "Quake Terminal" `
                    -TargetPath "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe" `
                    -Arguments '-w _quake -p "Command Prompt"' `
                    -IconPath "$env:USERPROFILE\winfiles\icons\app_icons\terminal.ico" `
                    -StartIn "$env:LOCALAPPDATA\Microsoft\WindowsApps" `
                    -WindowStyle 7  # Minimizes the terminal on startup

# Create startup shortcut for tpmiddle-rs on ThinkStation desktops
$chassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes
if ($chassisType -ge 3 -and $chassisType -le 7) {
    Set-StartupShortcut -Name "tpmiddle-rs" `
                        -TargetPath "$env:USERPROFILE\winfiles\bin\tpmiddle-rs.vbs"
}

# Create startup shortcut for MarbleScroll on ThinkPad laptops
if ($chassisType -ge 8 -and $chassisType -le 10) {
    Set-StartupShortcut -Name "MarbleScroll" `
                        -TargetPath "$env:USERPROFILE\winfiles\bin\MarbleScroll.exe"
}

# Install and register fonts
& "$PSScriptRoot\install_fonts.ps1"

# Make Explorer window titlebars and borders thinner
& "$PSScriptRoot\make_explorer_titlebars_thinner.ps1"

# Enable Developer Mode (allows symlink creation without elevation)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1

# Enable Hibernation (not on vm)
$systemModel = (Get-WmiObject -Class Win32_ComputerSystem).Model
if (-Not ($systemModel -match "Virtual|VMware|Hyper-V")) {
    Start-Process -FilePath "powercfg" -ArgumentList "/hibernate on" -Verb RunAs
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings' -Name 'ShowHibernateOption' -Value 1
}

# Set Registered Owner and Organisation
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOwner' -Value 'Jason Gomez'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOrganization' -Value 'Jinko Systems'

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'updateRDStatus' -Value 1
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1

# Set dark mode
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0

# Set taskbar to align to the left
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0

# Enable Show Desktop button at right edge of the taskbar
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSd' -Value 1

# Disable Snap Layouts on top of screen
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'EnableSnapBar' -Value 0

# Disable keyboard annoyances
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value 506
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name 'Flags' -Value 122
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name 'Flags' -Value 58

# Set global EULA acceptance for SysInternals tools
New-Item -Path 'HKCU:\Software\Sysinternals' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Sysinternals' -Name 'EulaAccepted' -Value 1

# Change PrtSc key to Context Menu key and AltGr to Alt on ThinkPad laptops
if ($chassisType -ge 8 -and $chassisType -le 10) {
    $scancodeMap = [byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                            0x03, 0x00, 0x00, 0x00, 0x5d, 0xe0, 0x37, 0xe0,
                            0x38, 0x00, 0x38, 0xe0, 0x00, 0x00, 0x00, 0x00)

    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' `
                     -Name 'Scancode Map' `
                     -Value $scancodeMap `
                     -Type Binary
}

# Disable Xbox Gamebar
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name GameDVR_Enabled -Type DWord -Value 0

# Windows features
if (-Not $env:bootstrapped) {

    # Enable
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Windows-Subsystem-Linux' | Out-Null
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'VirtualMachinePlatform' | Out-Null
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Containers-DisposableClientVM' | Out-Null
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Hyper-V-All' -All | Out-Null

    # Disable
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'WindowsMediaPlayer' | Out-Null
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Printing-XPSServices-Features' | Out-Null

}

# Remove some unwanted applications
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage

# Cleanup junk files (locations have been changed)
$delfiles = @(".gitconfig", ".lesshst", ".viminfo", "_viminfo", ".wget-hsts")
foreach ($file in $delfiles) {
    Remove-Item -Path "$env:USERPROFILE\$file" -Force -ErrorAction SilentlyContinue
}

# Hide top-level dotfiles and dotdirectories in $env:USERPROFILE
$dotfiles = Get-ChildItem -Path "$env:USERPROFILE\.*" -Force -Directory | Where-Object { -not ($_ | Get-ItemProperty -Name Attributes -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Attributes) -match 'Hidden' }
foreach ($file in $dotfiles) {
    Set-ItemProperty -Path $file.FullName -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
}

# Hide top-level dotfiles and dotdirectories in $env:USERPROFILE\winfiles
$winfilesDotfiles = Get-ChildItem -Path "$env:USERPROFILE\winfiles\.*" -Force -Directory | Where-Object { -not ($_ | Get-ItemProperty -Name Attributes -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Attributes) -match 'Hidden' }
foreach ($file in $winfilesDotfiles) {
    Set-ItemProperty -Path $file.FullName -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
}

# Set environment variable showing that this script has been run before
Set-ItemProperty -Path "HKCU:\Environment" -Name "bootstrapped" -Value "true"

# Check if a restart is required
$restartNeeded = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue)

if ($restartNeeded -and -Not $env:bootstrapped) {
    Write-Host "Restarting the computer to finish..." -ForegroundColor Yellow
    Restart-Computer
} elseif ($restartNeeded) {
    gum style --foreground 212 --border-foreground 212 --border double `
        --align center --width 50 --margin "1 2" --padding "2 4" `
        'Restart shell now for' 'environment variables to take effect'
}
