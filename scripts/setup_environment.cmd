@echo off

:: Sets symlinks in AppData for clink settings and dotfiles in repository
:: Hides dotfiles and dotdirectories in %USERPROFILE% and winfiles
:: Installs and registers fonts in font directory

if not exist %USERPROFILE%\AppData\Local\clink (
    mkdir %USERPROFILE%\AppData\Local\clink
)
if exist %USERPROFILE%\AppData\Local\clink\clink_start.cmd (
    del %USERPROFILE%\AppData\Local\clink\clink_start.cmd
)
mklink %USERPROFILE%\AppData\Local\clink\clink_start.cmd %USERPROFILE%\winfiles\scripts\clink_start.cmd
if exist %USERPROFILE%\AppData\Local\clink\clink_settings (
    del %USERPROFILE%\AppData\Local\clink\clink_settings
)
mklink %USERPROFILE%\AppData\Local\clink\clink_settings %USERPROFILE%\winfiles\Settings\clink_settings

if exist %USERPROFILE%\AppData\Local\clink\_inputrc (
    del %USERPROFILE%\AppData\Local\clink\_inputrc
)
mklink %USERPROFILE%\AppData\Local\clink\_inputrc %USERPROFILE%\winfiles\Settings\_inputrc

if exist %USERPROFILE%\.config (
    for /f "tokens=*" %%a in ('dir /s /b /ad "%USERPROFILE%\.config\*"') do move /y "%%~a" "%USERPROFILE%\winfiles\Settings\.config\"
    rmdir %USERPROFILE%\.config
)
mklink /d %USERPROFILE%\.config %USERPROFILE%\winfiles\Settings\.config
attrib /l +h %USERPROFILE%\.config

if exist %USERPROFILE%\.profile (
    del /a %USERPROFILE%\.profile
)
mklink %USERPROFILE%\.profile %USERPROFILE%\winfiles\Settings\.profile
attrib /l +h %USERPROFILE%\.profile

if exist %USERPROFILE%\.envrc (
    del /a %USERPROFILE%\.envrc
)
mklink %USERPROFILE%\.envrc %USERPROFILE%\winfiles\Settings\.envrc
attrib /l +h %USERPROFILE%\.envrc

for /f %%D in ('dir /b /a:-h %USERPROFILE%\.*') do attrib +h %USERPROFILE%\%%D
for /f %%E in ('dir /b /a:-h %USERPROFILE%\winfiles\.*') do attrib +h %USERPROFILE%\winfiles\%%E

set PATH=%USERPROFILE%\winfiles\bin;%PATH%
pushd %USERPROFILE%\winfiles\fonts
for /d %%F in (*) do pushd %%F & fontreg /copy & popd
popd

if exist %USERPROFILE%\AppData\Roaming\copyq (
    rd /s /q %USERPROFILE%\AppData\Roaming\copyq
)
mklink /d %USERPROFILE%\AppData\Roaming\copyq %USERPROFILE%\winfiles\Settings\copyq

if not exist %USERPROFILE%\AppData\Local\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState (
    mkdir %USERPROFILE%\AppData\Local\Packages\Microsoft\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
)
copy %USERPROFILE%\winfiles\Windows_Terminal\settings.json %USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
