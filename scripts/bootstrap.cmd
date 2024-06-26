@echo off

:: Automates the setup and configuration of the Windows environment
:: * Enables hibernation
:: * Install essential packages using winget
:: * Install scoop for multi-users and packages through PowerShell script
:: * Setup OpenSSH and retrieve key from Dashlane
:: * Retrieves current SSH key from Dashlane vault
:: * Sets up Clink, cloning relevant repositores for extra features
:: * Enables Developer Mode (allows symlink creation without elevation)
:: * Sparse clones Linux dotfiles repository
:: * Makes symlinks from configurations in this repository and .dotfiles
:: * Hides dotfiles and dotdirectories in %USERPROFILE% and winfiles
:: * Makes startup shortcuts for some systray applications
:: * Installs and registers fonts in font directory

:: TO DO:
:: * Translate to pure PowerShell at some point

net session >nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Not admin/elevated
    exit /b 1
)

setlocal EnableDelayedExpansion
set PATH=%PATH%;%USERPROFILE%\winfiles\bin\

:: Enable hibernation
powercfg /hibernate on

:: Take ownership of winfiles
icacls "%USERPROFILE%\winfiles" /setowner "%USERNAME%" /t

:: Install essential packages using winget
call "%~dp0install_packages.cmd"

:: Install scoop for multi-users and packages
dir %SCOOP% >nul 2>&1
if not %ERRORLEVEL% == 0 (
    powershell -File "%~dp0install_scoop.ps1"
)

:: Setup OpenSSH and retrieve key from Dashlane
powershell -ExecutionPolicy Bypass -File "%~dp0setup_openssh.ps1"

:: Enable Developer Mode
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx" /v "AllowDevelopmentWithoutDevLicense" /t REG_DWORD /d 1 /f >nul

:: Sparse checkout dotfiles
if not exist %USERPROFILE%\.dotfiles (
    cd %USERPROFILE%
    git clone --no-checkout --depth=1 --filter=tree:0 https://github.com/eggbean/.dotfiles.git
    cd %USERPROFILE%\.dotfiles
    git sparse-checkout set --no-cone /.gitattributes .git-crypt .githooks bin/scripts config
    git checkout
    icacls "%CD%" /setowner "%USERNAME%" /t
)

:: Add bin directory from Windows Defender's exclusion list, because some binaries are
:: getting false positives. This is a bit risky, so scheduled scans will be done.
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath ""$env:HOME\winfiles\bin"""

:: Setup Clink
if not exist %LOCALAPPDATA%\clink (
    mkdir %LOCALAPPDATA%\clink
)
if exist %LOCALAPPDATA%\clink\clink_start.cmd (
    del %LOCALAPPDATA%\clink\clink_start.cmd
)
mklink %LOCALAPPDATA%\clink\clink_start.cmd %USERPROFILE%\winfiles\scripts\clink_start.cmd
if exist %LOCALAPPDATA%\clink\clink_settings (
    del %LOCALAPPDATA%\clink\clink_settings
)
mklink %LOCALAPPDATA%\clink\clink_settings %USERPROFILE%\winfiles\Settings\clink_settings

if exist %LOCALAPPDATA%\clink\_inputrc (
    del %LOCALAPPDATA%\clink\_inputrc
)
mklink %LOCALAPPDATA%\clink\_inputrc %USERPROFILE%\winfiles\Settings\_inputrc

if defined CLINK_COMPLETIONS_DIR (
    if not exist "%CLINK_COMPLETIONS_DIR%" (
        git clone https://github.com/vladimir-kotikov/clink-completions.git %USERPROFILE%\winfiles\Settings\clink-completions
        clink installscripts "%USERPROFILE%\winfiles\Settings\clink-completions"
    )
)

if not exist %USERPROFILE%\winfiles\Settings\clink-gizmos (
    git clone https://github.com/chrisant996/clink-gizmos.git %USERPROFILE%\winfiles\Settings\clink-gizmos
    clink installscripts %USERPROFILE%\winfiles\Settings\clink-gizmos
)

:: Symlink gnupg configuration
if exist %APPDATA%\gnupg (
    if exist "%APPDATA%\gnupg\*" (
        rmdir /s /q %APPDATA%\gnupg
    )
)
if not exist %APPDATA%\gnupg (
    mklink /d %APPDATA%\gnupg %USERPROFILE%\.dotfiles\config\.gnupg
)

:: Symlink copyq configuration
if exist %APPDATA%\copyq (
    if exist "%APPDATA%\copyq\*" (
        rmdir /s /q %APPDATA%\copyq
    )
)
if not exist %APPDATA%\copyq (
    mklink /d %APPDATA%\copyq %USERPROFILE%\.dotfiles\config\.config\copyq
)

:: Symlink XnViewMP config
if exist %APPDATA%\XnViewMP (
    if exist "%APPDATA%\XnViewMP\*" (
        rmdir /s /q %APPDATA%\XnViewMP
    )
)
if not exist %APPDATA%\XnViewMP (
    mklink /d %APPDATA%\XnViewMP %USERPROFILE%\.dotfiles\config\.config\XnViewMP
)

:: Symlink gh configuration
if exist %APPDATA%\"GitHub CLI" (
    if exist "%APPDATA%\GitHub CLI\*" (
        rmdir /s /q %APPDATA%\"GitHub CLI"
    )
)
if not exist %APPDATA%\"GitHub CLI" (
    mklink /d %APPDATA%\"GitHub CLI" %USERPROFILE%\.dotfiles\config\.config\gh
)

:: Symlink mpv configuration
if exist %APPDATA%\mpv (
    if exist "%APPDATA%\mpv\*" (
        rmdir /s /q %APPDATA%\mpv
    )
)
if not exist %APPDATA%\mpv (
    mklink /d %APPDATA%\mpv %USERPROFILE%\.dotfiles\config\.config\mpv
)

:: Symlink qutebrowser configuration
if exist %APPDATA%\qutebrowser\config (
    if exist "%APPDATA%\qutebrowser\config\*" (
        rmdir /s /q %APPDATA%\qutebrowser\config
    )
)
if not exist %APPDATA%\qutebrowser (
    mkdir %APPDATA%\qutebrowser
)
mklink /d %APPDATA%\qutebrowser\config %USERPROFILE%\.dotfiles\config\.config\qutebrowser

:: Symlink vim configuration
if not exist %USERPROFILE%\vimfiles (
    mklink /d %USERPROFILE%\vimfiles %USERPROFILE%\.dotfiles\config\.config\vim
    attrib /l +h %USERPROFILE%\vimfiles
)
if not exist %USERPROFILE%\vimfiles.lnk (
    nircmd shortcut "%USERPROFILE%\.dotfiles\config\.config\vim" "%USERPROFILE%" vimfiles "%USERPROFILE%\winfiles\icons\my_icons\vimfiles.ico"
    echo vimfiles shortcut created
)

:: Copy any existing config files to repository
if exist %USERPROFILE%\.config (
    robocopy %USERPROFILE%\.config\ %USERPROFILE%\winfiles\Settings\.config\ /move /e /it /im >NUL
    rmdir %USERPROFILE%\.config >nul 2>&1
)
mklink /d %USERPROFILE%\.config %USERPROFILE%\winfiles\Settings\.config
attrib /l +h %USERPROFILE%\.config

:: Symlink dotfiles
for %%S in (.digrc .envrc .profile .ripgreprc) do (
    if exist %USERPROFILE%\%%S (
        del /a %USERPROFILE%\%%S
    )
    mklink %USERPROFILE%\%%S %USERPROFILE%\winfiles\Settings\%%S
    attrib /l +h %USERPROFILE%\%%S
)

:: Symlink WinSCP config
if not exist %LOCALAPPDATA%\Programs\WinSCP (
    mkdir%LOCALAPPDATA%\Programs\WinSCP
)
if exist %LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini (
    rm %LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini
    mklink %LOCALAPPDATA%\Programs\WinSCP\WinSCP.ini %USERPROFILE%\winfiles\Settings\WinSCP.ini
)

:: Copy SumatraPDF config
if not exist %LOCALAPPDATA%\SumatraPDF (
    mkdir %LOCALAPPDATA%\SumatraPDF
    copy %USERPROFILE%\winfiles\Settings\SumatraPDF-settings.txt %LOCALAPPDATA%\SumatraPDF
)

:: Symlink Windows Terminal config
if not exist %LOCALAPPDATA%\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState (
    mkdir %LOCALAPPDATA%\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
)
if exist %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json (
    del %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
)
if %USERNAME% == webadmin (
    mklink %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json %USERPROFILE%\winfiles\Windows_Terminal\settings-ubuntu.json
) else (
    mklink %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json %USERPROFILE%\winfiles\Windows_Terminal\settings.json
)

:: Make startup shortcut for CopyQ
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\copyq.lnk" (
    nircmd shortcut "C:\Program Files\CopyQ\copyq.exe" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" CopyQ
    echo CopyQ startup shortcut created
)

:: Determine computer chassis type
for /f "delims={}" %%i in ('wmic systemenclosure get chassistypes ^| findstr "{"') do @set "chassistype=%%i"`

:: Make startup shortcut for tpmiddle-rs on desktops
if %chassistype% GEQ 3 if %chassistype% LEQ 7 (
    if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\tpmiddle-rs.lnk" (
        nircmd shortcut "%USERPROFILE%\winfiles\bin\tpmiddle-rs.vbs" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" tpmiddle-rs
        echo tpmiddle-rs startup shortcut created
    )
)

:: Make startup shortcut for MarbleScroll on laptops
if %chassistype% GEQ 8 if %chassistype% LEQ 10 (
    if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\MarbleScroll.lnk" (
        nircmd shortcut "%USERPROFILE%\winfiles\MarbleScroll\MarbleScroll.exe" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" MarbleScroll
        echo MarbleScroll startup shortcut created
    )
)

:: Make startup shortcut for Sizer
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Sizer.lnk" (
    nircmd shortcut "C:\Program Files (x86)\Sizer\sizer.exe" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" Sizer
    echo Sizer startup shortcut created
)

:: Make startup shortcut for SylphyHornPlus11
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SylphyHorn.lnk" (
    nircmd shortcut "%USERPROFILE%\winfiles\SylphyHorn\SylphyHorn.exe" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" SylphyHorn
    echo SylphyHorn startup shortcut created
)

:: Make startup shortcut for Quake Terminal
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Quake Terminal.lnk" (
    nircmd shortcut "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" "Quake Terminal" "-w _quake -p ~qCommand Prompt~q" "%USERPROFILE%\winfiles\icons\app_icons\terminal.ico" "" min
    echo Quake Terminal startup shortcut created
)

:: Install fonts
pushd %USERPROFILE%\winfiles\fonts
for /d %%F in (*) do (
    pushd %%F
    for %%x in (*.ttf *.otf) do (
        set "fontInstalled=false"
        for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" ^| findstr /i "%%~nx"') do set "fontInstalled=true"
        if "!fontInstalled!"=="false" (
            %USERPROFILE%\winfiles\bin\fontreg /copy
            echo %%~nxF fonts installed
        )
    )
    popd
)
popd

:: Hide dotfiles and dotdirectories in %USERPROFILE% and winfiles
for /f %%D in ('dir /b /a:-h %USERPROFILE%\.*') do attrib +h %USERPROFILE%\%%D
for /f %%E in ('dir /b /a:-h %USERPROFILE%\winfiles\.*') do attrib +h %USERPROFILE%\winfiles\%%E

:: Set clink to autorun for all users
:: (this is done at the end as it seems to terminate the script)
clink autorun -a install >nul 2>&1
