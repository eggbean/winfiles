@echo on

:: Automates the setup and configuration of my Windows environment
:: * Exclude known false positives from Windows Defender scanning
:: * Install essential packages using winget
:: * Set icons for various folders
:: * Add vim to %PATH%
:: * Install scoop for multi-users and packages (if not already installed)
:: * Setup OpenSSH and retrieve SSH key from Dashlane vault
:: * Retrieve GPG private key from Dashlane if not present in GPG keyring
:: * Install the wedge redirector for the Chrometana Pro Chrome extension
:: * Setup Clink, cloning relevant repositories for extra features
:: * Sparse checkout Linux dotfiles repository
:: * Create symlinks between %APPDATA% and Linux dotfiles
:: * Create symlink for vimfiles from Linux dotfiles repository
:: * Create symlinks for configs in this repo to %HOME% and %LOCALAPPDATA%
:: * Make startup shortcuts for some systray applications
:: * Install and register fonts
:: * Set various OS settings through the registry
:: * Enable and Disable Windows Features
:: * Hide dotfiles and dotdirectories in %USERPROFILE% and winfiles

:: TO DO:
:: * Translate to do everything in pure PowerShell (Work In Progress)

:: Check for admin privileges
net session >NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Not admin/elevated
    exit /b 1
)

setlocal EnableDelayedExpansion
set PATH=%PATH%;%USERPROFILE%\winfiles\bin\

:: Exclude known false positives from Windows Defender scanning
powershell -File "%~dp0defender_whitelist.ps1"

:: Install essential packages using winget
call "%~dp0install_packages.cmd"

:: Set icons for various folders
call "%~dp0fix_icons.cmd"

:: Add vim to %PATH%
powershell -File "%~dp0add_vim_to_path.ps1"

:: Install scoop for multi-users and packages (if not already installed)
if not exist "%SCOOP%" (
    powershell -File "%~dp0install_scoop.ps1"
)

:: Setup OpenSSH and retrieve SSH key from Dashlane vault
powershell -File "%~dp0setup_openssh.ps1"

:: Retrieve GPG private key from Dashlane if not present in GPG keyring
powershell -File "%~dp0get_gpg_key.ps1"

:: Install the wedge redirector for the Chrometana Pro Chrome extension
powershell -File "%~dp0install_wedge.ps1"

:: Setup Clink, cloning relevant repositores for extra features
if not exist "%LOCALAPPDATA%\clink" (
    mkdir "%LOCALAPPDATA%\clink"
)
call :CreateSymlink "%LOCALAPPDATA%\clink\clink_start.cmd" "%USERPROFILE%\winfiles\scripts\clink_start.cmd"
call :CreateSymlink "%LOCALAPPDATA%\clink\clink_settings" "%USERPROFILE%\winfiles\Settings\clink_settings"
call :CreateSymlink "%LOCALAPPDATA%\clink\_inputrc" "%USERPROFILE%\winfiles\Settings\_inputrc"

if defined CLINK_COMPLETIONS_DIR if not exist "%CLINK_COMPLETIONS_DIR%" (
    git clone https://github.com/vladimir-kotikov/clink-completions.git "%USERPROFILE%\winfiles\Settings\clink-completions"
    clink installscripts "%USERPROFILE%\winfiles\Settings\clink-completions"
)

if not exist "%USERPROFILE%\winfiles\Settings\clink-gizmos" (
    git clone https://github.com/chrisant996/clink-gizmos.git "%USERPROFILE%\winfiles\Settings\clink-gizmos"
    clink installscripts "%USERPROFILE%\winfiles\Settings\clink-gizmos"
)

:: Take ownership of winfiles
icacls "%USERPROFILE%\winfiles" /setowner "%USERNAME%" /T >NUL
if %ERRORLEVEL% == 0 (
    echo Taken ownership of winfiles
) else (
    echo Error taking ownership of winfiles
    exit /b 1
)

:: Sparse checkout Linux dotfiles repository and decrypt
if not exist "%USERPROFILE%\.dotfiles" (
    cd "%USERPROFILE%"
    git clone --no-checkout --depth=1 --filter=tree:0 https://github.com/eggbean/.dotfiles.git
    cd "%USERPROFILE%\.dotfiles"
    git sparse-checkout set --no-cone /.gitattributes .git-crypt .githooks bin/scripts config
    git checkout
    icacls "%CD%" /setowner "%USERNAME%" /T
    git crypt unlock
)

:: Create symlinks between %APPDATA% and Linux dotfiles
call :CreateSymlink "%APPDATA%\gnupg" "%USERPROFILE%\.dotfiles\config\.gnupg"
call :CreateSymlink "%APPDATA%\copyq" "%USERPROFILE%\.dotfiles\config\.config\copyq"
call :CreateSymlink "%APPDATA%\XnViewMP" "%USERPROFILE%\.dotfiles\config\.config\XnViewMP"
call :CreateSymlink "%APPDATA%\GitHub CLI" "%USERPROFILE%\.dotfiles\config\.config\gh"
call :CreateSymlink "%APPDATA%\mpv" "%USERPROFILE%\.dotfiles\config\.config\mpv"
call :CreateSymlink "%APPDATA%\qutebrowser\config" "%USERPROFILE%\.dotfiles\config\.config\qutebrowser"

:: Create symlink for vimfiles from Linux dotfiles repository
call :CreateSymlink "%USERPROFILE%\vimfiles" "%USERPROFILE%\.dotfiles\config\.config\vim"
attrib /l +h "%USERPROFILE%\vimfiles"

:: Create vimfiles shortcut
if not exist "%USERPROFILE%\vimfiles.lnk" (
    nircmd shortcut "%USERPROFILE%\.dotfiles\config\.config\vim" "%USERPROFILE%" vimfiles "%USERPROFILE%\winfiles\icons\my_icons\vimfiles.ico"
    echo vimfiles shortcut created
)

:: Move and symlink .config
if exist "%USERPROFILE%\.config" (
    robocopy "%USERPROFILE%\.config\" "%USERPROFILE%\winfiles\Settings\.config\" /move /e /it /im >NUL
    rmdir "%USERPROFILE%\.config" >NUL 2>&1
)
call :CreateSymlink "%USERPROFILE%\.config" "%USERPROFILE%\winfiles\Settings\.config"

:: Symlink other dotfiles
for %%S in (.digrc .envrc .profile .ripgreprc) do (
    call :CreateSymlink "%USERPROFILE%\%%S" "%USERPROFILE%\winfiles\Settings\%%S"
)

:: Symlink WinSCP config
if not exist "%LOCALAPPDATA%\Programs\WinSCP" (
    mkdir "%LOCALAPPDATA%\Programs\WinSCP"
)
if exist "%LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini" (
    del "%LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini"
)
mklink "%LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini" "%USERPROFILE%\winfiles\Settings\WinSCP.ini"

:: Copy SumatraPDF config
if not exist "%LOCALAPPDATA%\SumatraPDF" (
    mkdir "%LOCALAPPDATA%\SumatraPDF"
    copy "%USERPROFILE%\winfiles\Settings\SumatraPDF-settings.txt" "%LOCALAPPDATA%\SumatraPDF"
)

:: Symlink Windows Terminal config
if not exist "%LOCALAPPDATA%\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" (
    mkdir "%LOCALAPPDATA%\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
)
if exist "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" (
    del "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
)
if "%USERNAME%" == "webadmin" (
    mklink "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "%USERPROFILE%\winfiles\Windows_Terminal\settings-ubuntu.json"
) else (
    mklink "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "%USERPROFILE%\winfiles\Windows_Terminal\settings.json"
)

:: Determine computer chassis type
for /f "delims={}" %%i in ('wmic systemenclosure get chassistypes ^| findstr "{"') do @set "chassistype=%%i"`

:: Create startup shortcuts
call :CreateStartupShortcut "CopyQ" "C:\Program Files\CopyQ\copyq.exe"
call :CreateStartupShortcut "Sizer" "C:\Program Files (x86)\Sizer\sizer.exe"
call :CreateStartupShortcut "SylphyHorn" "%USERPROFILE%\winfiles\SylphyHorn\SylphyHorn.exe"
call :CreateStartupShortcut "Quake Terminal" "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" "-w _quake -p ~qCommand Prompt~q" "%USERPROFILE%\winfiles\icons\app_icons\terminal.ico" "" "min"

:: Create startup shortcut for tpmiddle-rs on ThinkStation desktops
if %chassistype% GEQ 3 if %chassistype% LEQ 7 (
    call :CreateStartupShortcut "tpmiddle-rs" "%USERPROFILE%\winfiles\bin\tpmiddle-rs.vbs"
)

:: Create startup shortcut for MarbleScroll on ThinkPad laptops
if %chassistype% GEQ 8 if %chassistype% LEQ 10 (
    call :CreateStartupShortcut "MarbleScroll" "%USERPROFILE%\winfiles\bin\MarbleScroll.exe"
)

:: Install extra scoop package on ThinkPad laptops
if %chassistype% GEQ 8 if %chassistype% LEQ 10 (
    scoop list batteryinfoview >NUL 2>&1
    if %ERRORLEVEL% NEQ 0 (
        scoop install nirsoft/batteryinfoview -u -g
    )
)

:: Install and register fonts
pushd "%USERPROFILE%\winfiles\fonts"
for /d %%F in (*) do (
    pushd %%F
    for %%x in (*.ttf *.otf) do (
        set "fontInstalled=false"
        for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" ^| findstr /i "%%~nx"') do set "fontInstalled=true"
        if "!fontInstalled!"=="false" (
            "%USERPROFILE%\winfiles\bin\fontreg" /copy
            echo %%~nxF fonts installed
        )
    )
    popd
)
popd

:: Enable Developer Mode (allows symlink creation without elevation)
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1"

:: Enable Hibernation
powercfg /hibernate on
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings' -Name 'ShowHibernateOption' -Value 1"

:: Set Registered Owner and Organisation
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOwner' -Value 'Jason Gomez'"
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'RegisteredOrganization' -Value 'Jinko Systems'"

:: Enable Remote Desktop
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0"
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'updateRDStatus' -Value 1"
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1"

:: Set dark mode
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0"
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0"

:: Set taskbar to align to the left
powershell -Command "Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0"

:: Enable Show Desktop button at right edge of the taskbar
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSd' -Value 1"

:: Disable Snap Layouts on top of screen
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'EnableSnapBar' -Value 0"

:: Disable keyboard annoyances
powershell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value 506"
powershell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name 'Flags' -Value 122"
powershell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name 'Flags' -Value 58"

:: Set global EULA acceptance for SysInternals tools
powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Sysinternals' -Name 'EulaAccepted' -Value 1"

:: Enable Windows Features
powershell -Command "Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' | Out-Null"
powershell -Command "Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName 'VirtualMachinePlatform' | Out-Null"
powershell -Command "Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName 'Containers-DisposableClientVM' | Out-Null"

:: Disable Windows Features
powershell -Command "Disable-WindowsOptionalFeature -NoRestart -Online -FeatureName 'WindowsMediaPlayer' | Out-Null"
powershell -Command "Disable-WindowsOptionalFeature -NoRestart -Online -FeatureName 'Printing-XPSServices-Features' | Out-Null"

:: Hide dotfiles and dotdirectories in %USERPROFILE% and winfiles
for /f %%D in ('dir /b /a:-h "%USERPROFILE%\.*"') do attrib +h "%USERPROFILE%\%%D"
for /f %%E in ('dir /b /a:-h "%USERPROFILE%\winfiles\.*"') do attrib +h "%USERPROFILE%\winfiles\%%E"

:: Set clink to autorun for all users
:: (this is done at the end as it seems to terminate the script)
clink autorun -a install >NUL 2>&1
exit /b 0

:: Function to create symlink after deleting existing directory
:CreateSymlink
if exist "%1" (
    rmdir /s /q "%1"
)
mklink /d "%1" "%2"
goto :eof

:: Function to create a startup shortcut using nircmd
:CreateStartupShortcut
setlocal
set "name=%~1"
set "target=%~2"
set "arguments=%~3"
set "icon=%~4"
set "start_in=%~5"
set "window_style=%~6"
set "shortcut_path=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\%name%.lnk"
if not exist "%shortcut_path%" (
    nircmd shortcut "%target%" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" "%name%" "%icon%" "%start_in%" "%arguments%" "%window_style%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create shortcut for %name%. Error code: %ERRORLEVEL%
    ) else (
        echo %name% startup shortcut created.
    )
) else (
    echo %name% shortcut already exists. Skipping creation.
)
endlocal
goto :eof
