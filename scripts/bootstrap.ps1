# Start timing the script
$startTime = Get-Date

# Ensure the script is run with administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-Not $isAdmin) {
    Write-Error "This script needs to be run as Administrator."
    exit 1
}

# Parse command-line arguments
$Rename = $null
$SkipPackages = $false
$LogScript = $false
for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq "--rename" -and $i + 1 -lt $args.Count) {
        $Rename = $args[$i + 1]
    }
    elseif ($args[$i] -eq "--skip-packages") {
        $SkipPackages = $true
    }
    elseif ($args[$i] -eq "--log") {
        $LogScript = $true
    }
}

# If first run log automatically
# and don't skip packages as the script will fail
if (-Not $env:bootstrapped) {
    $LogScript = $true
    $SkipPackages = $false
}

# Start logging with --log argument
if ($LogScript) {
    Start-Transcript -Path "$env:USERPROFILE\bootstrap_log.log" -Append
}

# Rename computer with --rename argument
if ($Rename) {
    Write-Host "Current computer name: $env:COMPUTERNAME"
    try {
        Rename-Computer -NewName $Rename -Force
        Write-Host "Computer name changed successfully to '$Rename'."
    }
    catch {
        Write-Error "Failed to rename the computer. Error: $_"
        exit 1
    }
}

# Import modules
Import-Module -Name "$PSScriptRoot\Set-FileTypeIcon.psm1"
Import-Module -Name "$PSScriptRoot\Set-FolderIcon.psm1"
Import-Module -Name "$PSScriptRoot\Set-StartMenuShortcut.psm1"
Import-Module -Name "$PSScriptRoot\Set-StartupShortcut.psm1"
Import-Module -Name "$PSScriptRoot\Set-Symlink.psm1"
Import-Module -Name "$PSScriptRoot\Unlock-Repository.psm1"
Import-Module -Name "$PSScriptRoot\Wait-WithCancel.psm1"

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

# Install scoop for multi-users and packages
if (-Not $SkipPackages) {
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

# Create symlink for vimfiles from Linux dotfiles repository
Set-Symlink "$env:USERPROFILE\vimfiles" "$env:USERPROFILE\.dotfiles\config\.config\vim"
$symlink = Get-Item "$env:USERPROFILE\vimfiles"; $symlink.Attributes = $symlink.Attributes -bor [System.IO.FileAttributes]::System

# Create symlink for CopyQ from Linux dotfiles repository (for easier access to database files)
Set-Symlink "$env:USERPROFILE\CopyQ" "$env:USERPROFILE\.dotfiles\config\.config\copyq"
$symlink = Get-Item "$env:USERPROFILE\CopyQ"; $symlink.Attributes = $symlink.Attributes -bor [System.IO.FileAttributes]::System

# Create symlinks between $APPDATA and this repository
$link = "$env:LOCALAPPDATA\Packages\48914EllipticPhenomena.OnePhotoViewer_8w313s78tpvfc\LocalCache\Local\One Photo Viewer\OnePhotoViewer.config"
$target = "$env:USERPROFILE\winfiles\Settings\AppData\OnePhotoViewer.config"
Set-Symlink $link $target
Set-Symlink "$env:LOCALAPPDATA\Programs\WinSCP\WinSCP.ini" "$env:USERPROFILE\winfiles\Settings\AppData\WinSCP.ini"

# Setup OpenSSH and retrieve SSH key from Dashlane vault
$sshSetupStartTime = Get-Date
& "$PSScriptRoot\setup_openssh.ps1"
$sshSetupEndTime = Get-Date

# Calculate the time taken for OpenSSH setup
$sshSetupTime = $sshSetupEndTime - $sshSetupStartTime

# Move any existing known_hosts files and symlink .ssh directory
$sshDir = "$env:USERPROFILE\.ssh"
$sshRepoDir = "$env:USERPROFILE\winfiles\Settings\.ssh"
$knownHostsPattern = "$sshDir\known_hosts*"
$knownHostsFiles = Get-ChildItem -Path $knownHostsPattern -ErrorAction SilentlyContinue
if ($knownHostsFiles) {
    foreach ($file in $knownHostsFiles) {
        Move-Item -Path $file.FullName -Destination $sshRepoDir -Force
    }
}
Set-Symlink $sshDir $sshRepoDir
(Get-Item $sshDir -Force).Attributes += 'Hidden'

# Retrieve GPG private key from Dashlane if not present in GPG keyring
& "$PSScriptRoot\get_gpg_key.ps1"
Write-Output y | & "$env:USERPROFILE\winfiles\bin\dcli" logout | Out-Null

# Decrypt repositories if locked
if ($env:bootstrapped) {
    Get-Process | Where-Object { $_.Name -like "*gpg*" } | Stop-Process -Force
    Remove-Item "$env:APPDATA\gnupg\*.lock" -Force -ErrorAction SilentlyContinue
    $repos = @("$env:USERPROFILE\winfiles", "$env:USERPROFILE\.dotfiles")
    Start-Sleep -Seconds 2
    foreach ($repo in $repos) {
        Unlock-Repository $repo
    }
}

# Add vim to $PATH
& "$PSScriptRoot\add_vim_to_path.ps1"

# Set environment variables
Set-ItemProperty -Path "HKCU:\Environment" -Name "BROWSER"                  -Value "C:\Program Files\qutebrowser\qutebrowser.exe"
Set-ItemProperty -Path "HKCU:\Environment" -Name "EDITOR"                   -Value "vim"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GEOIPUPDATE_CONF_FILE"    -Value "$env:APPDATA\geoipupdate\GeoIP.conf"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GEOIPUPDATE_LOCK_FILE"    -Value "$env:APPDATA\geoipupdate\_geoipupdate.lock"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GH_BROWSER"               -Value "C:\\Program\ Files\\qutebrowser\\qutebrowser.exe"
Set-ItemProperty -Path "HKCU:\Environment" -Name "GNUPGHOME"                -Value "$env:APPDATA\gnupg"
Set-ItemProperty -Path "HKCU:\Environment" -Name "HOME"                     -Value "$env:USERPROFILE"
Set-ItemProperty -Path "HKCU:\Environment" -Name "LESS"                     -Value "-MRQx4F#10"
Set-ItemProperty -Path "HKCU:\Environment" -Name "LESSHISTFILE"             -Value "$env:APPDATA\_lesshst"
Set-ItemProperty -Path "HKCU:\Environment" -Name "RIPGREP_CONFIG_PATH"      -Value "$env:USERPROFILE\.config\ripgrep\ripgreprc"
Set-ItemProperty -Path "HKCU:\Environment" -Name "VAGRANT_DEFAULT_PROVIDER" -Value "hyperv"
Set-ItemProperty -Path "HKCU:\Environment" -Name "WGET2RC"                  -Value "$env:USERPROFILE\.config\wget\wget2rc"

# Set LS_COLORS environment variable using dircolors from uutils-coreutils
$dirColorsCommand = 'dircolors -c "$env:USERPROFILE\winfiles\scripts\dir_colors"'
$dirColorsOutput = Invoke-Expression $dirColorsCommand
$lsColorsValue = $dirColorsOutput -replace '^setenv\s+LS_COLORS\s+', ''
$lsColorsValue = $lsColorsValue.Trim("'")
Set-ItemProperty -Path "HKCU:\Environment" -Name "LS_COLORS" -Value $lsColorsValue

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

# Copy any existing configuration files to winfiles
# and symlink .config from winfiles
$configPath = "$env:USERPROFILE\.config"
$targetPath = "$env:USERPROFILE\winfiles\Settings\.config"
if (Test-Path $configPath -PathType Container) {
    $item = Get-Item $configPath -Force
    if (-Not ($item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint))) {
		Write-Host "ROBOCOPY WILL EXECUTE!"
        robocopy $configPath $targetPath /move /e /it /im > $null
    }
}
Set-Symlink $configPath $targetPath
(Get-Item $configPath -Force).Attributes += 'Hidden'

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

# Write default PowerShell $profile if it does not exist
$profileDirectory = Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) "PowerShell"
$profilePath = Join-Path $profileDirectory "Microsoft.PowerShell_profile.ps1"
if (-Not (Test-Path $profileDirectory)) {
    New-Item -Path $profileDirectory -ItemType Directory -Force
}
if (-Not (Test-Path $profilePath)) {
    $profileUri = 'https://gist.githubusercontent.com/eggbean/81e7d1be5e7302c281ccc9b04134949e/raw/$profile'
    Invoke-WebRequest -Uri $profileUri -OutFile $profilePath
}

# Set a scheduled task to set file associations at logon
$taskName = "RunSetUserFTA"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if (-Not $task) {
    $action = New-ScheduledTaskAction `
        -Execute "cmd.exe" `
        -Argument "/c start /min `"$env:USERPROFILE\winfiles\bin\SetUserFTA.exe`" `"$PSScriptRoot\fileassociations.txt`""

    $trigger = New-ScheduledTaskTrigger -AtLogOn

    $principal = New-ScheduledTaskPrincipal `
        -UserId "NT AUTHORITY\SELF" `
        -LogonType Interactive `
        -RunLevel Limited

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RestartInterval (New-TimeSpan -Minutes 15) `
        -RestartCount 3

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Force
}

# Set the filetype icons for a specific file extensions
Set-FileTypeIcon -Extension '.bak'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.bind'      -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.btlic'     -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.config'    -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.gitignore' -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.hidden'    -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.inf'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.ini'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.inputrc'   -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.js'        -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.json'      -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.jsonc'     -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.log'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.md'        -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.notes'     -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.ps1'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.psd1'      -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.psm1'      -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.rst'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.srt'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.txt'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\shell32_16822.ico"
Set-FileTypeIcon -Extension '.vim'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.xml'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"
Set-FileTypeIcon -Extension '.yml'       -IconPath "$env:USERPROFILE\winfiles\icons\filetypes\svg.ico"

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
Set-FolderIcon "$env:USERPROFILE\Go" "%USERPROFILE%\winfiles\icons\my_icons\golang.ico" -Create
Set-FolderIcon "$env:USERPROFILE\My Drive" "%USERPROFILE%\winfiles\icons\my_icons\google_drive.ico" "Your Google Drive folder contains files that you're syncing with Google."
Set-FolderIcon "$env:USERPROFILE\iCloudDrive" "%USERPROFILE%\winfiles\icons\my_icons\iCloud Folder.ico" "iCloud Drive" "iCloud Drive"
Set-FolderIcon "$env:USERPROFILE\winfiles" "%USERPROFILE%\winfiles\icons\my_icons\microsoft_windows_11.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Clink" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Settings" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\SylphyHorn" "%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Vagrant" "%USERPROFILE%\winfiles\icons\my_icons\Vagrant.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\Windows_Terminal" "%USERPROFILE%\winfiles\icons\my_icons\terminal.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\bin" "%USERPROFILE%\winfiles\icons\my_icons\bat.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\fonts" "%USERPROFILE%\winfiles\icons\my_icons\fonts.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\icons" "%USERPROFILE%\winfiles\icons\my_icons\Apps Folder.ico"
Set-FolderIcon "$env:USERPROFILE\winfiles\icons\WSL" "%USERPROFILE%\winfiles\icons\my_icons\windows_subsystem_for_linux.ico"
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

# Create startup shortcut for tpmiddle-rs on my ThinkStation desktops
$chassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes[0]
if ($chassisType -ge 3 -and $chassisType -le 7 -and $env:USERNAME -ne "vagrant") {
    Set-StartupShortcut -Name "tpmiddle-rs" `
                        -TargetPath "$env:USERPROFILE\winfiles\bin\tpmiddle-rs.vbs"
}

# Create startup shortcut for MarbleScroll on my ThinkPad laptops
if (($chassisType -ge 8 -and $chassisType -le 10) -or $env:USERNAME -eq "vagrant") {
    Set-StartupShortcut -Name "MarbleScroll" `
                        -TargetPath "$env:USERPROFILE\winfiles\bin\MarbleScroll.exe"
}

# Fix missing StartMenu Shortcuts if packages were installed using another account
if ($env:USERNAME -ne "jason" -and $env:USERNAME -ne "vagrant") {
    Set-StartMenuShortcut -Subdir "WinDirStat" -Name "WinDirStat" -Target "$env:ProgramFiles(x86)\WinDirStat\windirstat.exe"
    Set-StartMenuShortcut -Subdir "WinDirStat" -Name "Help (ENG)" -Target "$env:ProgramFiles(x86)\WinDirStat\windirstat.chm"
}

# Install and register fonts
& "$PSScriptRoot\install_fonts.ps1"

# Make Explorer window titlebars and borders thinner
& "$PSScriptRoot\make_explorer_titlebars_thinner.ps1"

# Setup WSL2 and Ubuntu distro
if (-Not $env:bootstrapped) {
    & "$PSScriptRoot\setup_wsl2.ps1"
    if ($env:USERNAME -ne "jason") {
        winget install -e --id Canonical.Ubuntu
    }
}

# Change Task Manager refresh rate to Low and hide when minimised
if (-Not $env:bootstrapped) {
    $settingsFile = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\TaskManager\settings.json"
    $tempFile = Join-Path $env:TEMP "taskmgr.json"
    Start-Process -FilePath "taskmgr.exe"
    Start-Sleep -Seconds 2
    1..10 | ForEach-Object {
        if (Test-Path $settingsFile) { return }
        Start-Sleep -Seconds 1
    }
    Stop-Process -Name "Taskmgr" -Force
    jq '.RefreshRate = 4000 | .HideWhenMin = true' $settingsFile | Set-Content $tempFile
    Move-Item $tempFile $settingsFile -Force
}

# Set British keyboard
Set-WinUserLanguageList -LanguageList 'en-GB' -Force

# Set UAC level to default (the vagrant box I'm using turns UAC off)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1


# Enable Developer Mode (allows symlink creation without elevation)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1

# Enable Hibernation (not on vm)
$systemModel = (Get-WmiObject -Class Win32_ComputerSystem).Model
if (-Not ($systemModel -match "Virtual|VMware|Hyper-V")) {
    Start-Process -FilePath 'powercfg' -ArgumentList '/hibernate on' -Verb RunAs
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings' -Name 'ShowHibernateOption' -Value 1
}

# Set Registered Owner and Organisation
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOwner' -Value 'Jason Gomez'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOrganization' -Value 'Jinko Systems'

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'updateRDStatus' -Value 1
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1

# Set display scaling to 100%
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'LogPixels' -Value 96       # 96 DPI = 100% scaling
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'Win8DpiScaling' -Value 1   # Enables custom scaling

# Set dark mode
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0

# Set taskbar to align to the left
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0

# Enable Show Desktop button at right edge of the taskbar
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSd' -Value 1

# Change Search box on taskbar to icon only
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 1

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
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Containers-DisposableClientVM' | Out-Null
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Hyper-V-All' -All | Out-Null

    # Disable
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'WindowsMediaPlayer' | Out-Null
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Printing-XPSServices-Features' | Out-Null

}

# Remove some unwanted applications
# (there isn't any crapware in the Lenovo ThinkPad
# and ThinkStation Windows images that I use)
Get-AppxPackage Microsoft.GetHelp     | Remove-AppxPackage
Get-AppxPackage Microsoft.Getstarted  | Remove-AppxPackage
Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage

# Cleanup junk files (locations have been changed)
$delfiles = @(".gitconfig", ".lesshst", ".viminfo", "_viminfo", ".wget-hsts")
foreach ($file in $delfiles) {
    Remove-Item -Path "$env:USERPROFILE\$file" -Force -ErrorAction SilentlyContinue
}

# Delete application desktop shortcuts on first run
if (-Not $env:bootstrapped) {
    $userDesktopPath = [System.Environment]::GetFolderPath('Desktop')
    $publicDesktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
    $shortcuts = Get-ChildItem -Path $userDesktopPath, $publicDesktopPath -Filter *.lnk
    if ($shortcuts.Count -gt 0) {
        $shortcuts | Remove-Item -Force
        Write-Host "Desktop shortcuts removed."
    }
}

# Hide top-level dotfiles and dotdirectories in USERPROFILE and USERPROFILE\winfiles
$paths = @("$env:USERPROFILE", "$env:USERPROFILE\winfiles")
foreach ($path in $paths) {
    Get-ChildItem -Path "$path\.*" -Force |
    Where-Object { -not ($_.Attributes -band [System.IO.FileAttributes]::Hidden) } |
    ForEach-Object { $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden }
}

# Trigger post-checkout git hook to build Windows Terminal config
git checkout $env:USERPROFILE\winfiles\.githooks\post-checkout *> $null

# After first run, run script again after reboot (to unlock encrypted repositories)
$taskName = "RunAgainAtLogin"
$scriptPath = "$env:USERPROFILE\winfiles\scripts\bootstrap.ps1"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if (-not $env:bootstrapped) {
    if (Test-Path $scriptPath) {
        $taskDescription = "Runs bootstrap again when the user logs in"
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
            -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" --skip-packages -NoExit" `
            -WorkingDirectory "$env:USERPROFILE\winfiles\scripts"
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:UserName
        $userId = "$env:UserDomain\$env:UserName"
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd
        if (-Not $task) {
            Register-ScheduledTask -TaskName $taskName -Description $taskDescription `
                -Action $action -Trigger $trigger -Principal $principal -Settings $settings
            Write-Host "Scheduled task '$taskName' has been created successfully."
        }
    }
} else {
    if ($task) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Scheduled task '$taskName' has been deleted."
    }
}

# Set environment variable showing that this script has been run before
Set-ItemProperty -Path "HKCU:\Environment" -Name "bootstrapped" -Value "true"

# Calculate hours, minutes, and seconds from the total seconds
$endTime = Get-Date
$executionTime = ($endTime - $startTime) - $sshSetupTime
$timeTaken = $executionTime.TotalSeconds
$hours = [math]::Floor($timeTaken / 3600)
$minutes = [math]::Floor(($timeTaken % 3600) / 60)
$seconds = [math]::Floor($timeTaken % 60)
$timeTakenFormatted = "{0}:{1:00}:{2:00}" -f $hours, $minutes, $seconds

# Check if a restart is required
$restartNeeded = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue)

# Print execution time to terminal
Write-Host "Time taken: $timeTakenFormatted"

# Stop logging
if ($LogScript) {
    Start-Transcript -Path "$env:USERPROFILE\bootstrap_log.log" -Append
}

# Finish up
if ($restartNeeded -and -Not $env:bootstrapped) {
    Write-Host "Restarting the computer to finish..." -ForegroundColor Yellow
    Wait-WithCancel -WaitTime 15 -Message "Bootstrap will run again after rebooting..." -ShowCountdown
    Restart-Computer
} elseif ($restartNeeded) {
    gum style --foreground 212 --border-foreground 212 --border double `
        --align center --width 50 --margin "1 2" --padding "2 4" `
        'Restart the computer now' 'to finish setup'
}
