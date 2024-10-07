# Check if the script is running with admin privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-Not $isAdmin) {
    Write-Output "Not admin/elevated"
    exit 1
}

# Import modules
Import-Module -Name "$PSScriptRoot\Set-Symlink.psm1"
Import-Module -Name "$PSScriptRoot\Set-StartupShortcut.psm1"

# Exclude known false positives from Windows Defender scanning
& "$PSScriptRoot\defender_whitelist.ps1"

$SkipPackages = $false
if ($args.Count -gt 0 -and $args[0] -eq "--skip-packages") {
    $SkipPackages = $true
}

# Install winget packages
if (-Not $SkipPackages) {
    if (-Not $env:bootstrapped) {
        # Uninstall Git using winget
        winget uninstall -e --id Git.Git
    }
    & "$PSScriptRoot\install_packages.ps1"
}

# Set icons for various folders
& "$PSScriptRoot\fix_icons.ps1"

# Add vim to $PATH
& "$PSScriptRoot\add_vim_to_path.ps1"

# Install scoop for multi-users and packages (if not already installed)
if (-Not $env:bootstrapped) {
    & "$PSScriptRoot\install_scoop.ps1"
}

# Setup OpenSSH and retrieve SSH key from Dashlane vault
& "$PSScriptRoot\setup_openssh.ps1"
Set-Symlink "$env:USERPROFILE\.ssh" "$env:USERPROFILE\winfiles\Settings\.ssh"
Set-ItemProperty -Path "$env:USERPROFILE\.ssh" -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

# Install the wedge redirector for the Chrometana Pro Chrome extension
if (-Not $SkipPackages) {
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

# Sparse checkout Linux .dotfiles repository and decrypt
$dotfilesPath = "$env:USERPROFILE\.dotfiles"
if (-Not (Test-Path $dotfilesPath)) {
    Set-Location $env:USERPROFILE
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
        Write-Output "Error taking ownership of .dotfiles: $_"
        exit 1
    }
    git crypt unlock
    Stop-Process -Name "keyboxd" -Force
}

# Create symlinks between $APPDATA and Linux dotfiles
Set-Symlink "$env:APPDATA\GitHub CLI"         "$env:USERPROFILE\.dotfiles\config\.config\gh"
Set-Symlink "$env:APPDATA\XnViewMP"           "$env:USERPROFILE\.dotfiles\config\.config\XnViewMP"
Set-Symlink "$env:APPDATA\copyq"              "$env:USERPROFILE\.dotfiles\config\.config\copyq"
Set-Symlink "$env:APPDATA\geoipupdate"        "$env:USERPROFILE\.dotfiles\config\.config\geoipupdate"
Set-Symlink "$env:APPDATA\gnupg"              "$env:USERPROFILE\.dotfiles\config\.gnupg"
Set-Symlink "$env:APPDATA\mpv"                "$env:USERPROFILE\.dotfiles\config\.config\mpv"
Set-Symlink "$env:APPDATA\qutebrowser\config" "$env:USERPROFILE\.dotfiles\config\.config\qutebrowser"
Set-Symlink "$env:APPDATA\tlrc"               "$env:USERPROFILE\.dotfiles\config\.config\tlrc"

# Create symlink for vimfiles from Linux dotfiles repository
Set-Symlink "$env:USERPROFILE\vimfiles" "$env:USERPROFILE\.dotfiles\config\.config\vim"
attrib /l +h "$env:USERPROFILE\vimfiles"

# Create vimfiles shortcut
$shortcutPath = "$env:USERPROFILE\vimfiles.lnk"
if (-Not (Test-Path $shortcutPath)) {
    $ws = New-Object -ComObject WScript.Shell
    $shortcut = $ws.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$env:USERPROFILE\.dotfiles\config\.config\vim"
    $shortcut.IconLocation = "$env:USERPROFILE\winfiles\icons\my_icons\vimfiles.ico"
    $shortcut.Save()
    Write-Output "vimfiles shortcut created"
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
                        -TargetPath "%USERPROFILE%\winfiles\bin\tpmiddle-rs.vbs"
}

# Create startup shortcut for MarbleScroll on ThinkPad laptops
if ($chassisType -ge 8 -and $chassisType -le 10) {
    Set-StartupShortcut -Name "MarbleScroll" `
                        -TargetPath "%USERPROFILE%\winfiles\bin\MarbleScroll.exe"
}

# Install and register fonts
& "$PSScriptRoot\install_fonts.ps1"

# Make Explorer window titlebars and borders thinner
& "$PSScriptRoot\make_explorer_titlebars_thinner.ps1"

# Enable Developer Mode (allows symlink creation without elevation)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1

# Enable Hibernation (not on vm)
if ($env:USERNAME -eq "jason") {
    powercfg /hibernate on
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

if (-Not $env:bootstrapped) {

    # Enable Windows Features
    Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM' | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All' -All | Out-Null

    # Disable Windows Features
    Disable-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' | Out-Null
    Disable-WindowsOptionalFeature -Online -FeatureName 'Printing-XPSServices-Features' | Out-Null

}

# Cleanup shrapnel files
$delfiles = @(".gitconfig", ".lesshst", ".viminfo", "_viminfo", ".wget-hsts")
foreach ($file in $delfiles) {
    Remove-Item -Path "$env:USERPROFILE\$file" -Force -ErrorAction SilentlyContinue
}

# Set environment variable showing that this script has been run before
Set-ItemProperty -Path "HKCU:\Environment" -Name "bootstrapped" -Value "true"

gum style --foreground 212 --border-foreground 212 --border double `
    --align center --width 50 --margin "1 2" --padding "2 4" `
    'Restart shell for environment variables to take effect'
