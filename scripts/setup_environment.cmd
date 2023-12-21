@echo off

:: Clones Linux dotfiles repository and makes relevant symlinks to AppData
:: Sets symlinks in AppData for clink settings and dotfiles in this repository
:: Hides dotfiles and dotdirectories in %USERPROFILE% and winfiles
:: Installs and registers fonts in font directory

net session >nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Not admin/elevated
    exit /b 1
)

call %~dp0GITHUB_API_KEY.cmd

:: Sparse checkout dotfiles
if not exist %USERPROFILE%\.dotfiles (
    cd %USERPROFILE%
    git clone --no-checkout --depth=1 --filter=tree:0 https://%GITHUB_API_KEY%@github.com/eggbean/.dotfiles.git
)
cd %USERPROFILE%\.dotfiles
git sparse-checkout set --no-cone /.gitattributes .git-crypt bin/scripts config
git checkout

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
)

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

if not exist %CLINK_COMPLETIONS_DIR% (
    git clone https://github.com/vladimir-kotikov/clink-completions.git %USERPROFILE%\winfiles\Settings\clink-completions
)

:: Copy any existing config files to repository
if exist %USERPROFILE%\.config (
    robocopy %USERPROFILE%\.config\ %USERPROFILE%\winfiles\Settings\.config\ /move /e /it /im >NUL
    rmdir %USERPROFILE%\.config >nul 2>&1
)
mklink /d %USERPROFILE%\.config %USERPROFILE%\winfiles\Settings\.config
attrib /l +h %USERPROFILE%\.config

:: Symlink ~/.profile
if exist %USERPROFILE%\.profile (
    del /a %USERPROFILE%\.profile
)
mklink %USERPROFILE%\.profile %USERPROFILE%\winfiles\Settings\.profile
attrib /l +h %USERPROFILE%\.profile

:: Symlink ~/.envrc
if exist %USERPROFILE%\.envrc (
    del /a %USERPROFILE%\.envrc
)
mklink %USERPROFILE%\.envrc %USERPROFILE%\winfiles\Settings\.envrc
attrib /l +h %USERPROFILE%\.envrc

:: Hide dotfiles and dotdirectories in %USERPROFILE% and winfiles
for /f %%D in ('dir /b /a:-h %USERPROFILE%\.*') do attrib +h %USERPROFILE%\%%D
for /f %%E in ('dir /b /a:-h %USERPROFILE%\winfiles\.*') do attrib +h %USERPROFILE%\winfiles\%%E

:: Install fonts
pushd %USERPROFILE%\winfiles\fonts
for /d %%F in (*) do pushd %%F & %USERPROFILE%\winfiles\bin\fontreg /copy & popd
popd

:: Symlink SumatraPDF config
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
mklink %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json %USERPROFILE%\winfiles\Windows_Terminal\settings.json
