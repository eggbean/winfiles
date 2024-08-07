@echo off

:: It's unfortunate that this script is necessary, but some installers don't add start menu
:: shortcuts for All Users even when the winget `--scope machine` option is specified, so they
:: need to be created for users other than the one which was originally used to install the program.

:: Create Start Menu shortcuts
call :CreateStartMenuShortcut "WinDirStat" "WinDirStat" "%ProgramFiles(x86)%\WinDirStat\windirstat.exe"
call :CreateStartMenuShortcut "WinDirStat" "Help (ENG)" "%ProgramFiles(x86)%\WinDirStat\windirstat.chm"

exit /b 0

:CreateStartMenuShortcut
setlocal
set "subdir=%~1"
set "name=%~2"
set "target=%~3"
set "subdir_path=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%subdir%"
set "shortcut_path=%subdir_path%\%name%.lnk"

if not exist "%subdir_path%" (
    mkdir "%subdir_path%"
)

if not exist "%shortcut_path%" (
    nircmd shortcut "%target%" "%subdir_path%" "%name%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create shortcut for "%name%". Error code: %ERRORLEVEL%
    ) else (
        echo "%name%" startup shortcut created.
    )
)

endlocal
goto :eof
