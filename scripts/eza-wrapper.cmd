@echo off
setlocal enabledelayedexpansion

:: Default options
set "dot=0"
set "hru=1"
set "meb=0"
set "fgp=0"
set "lnk=0"
set "git=1"
set "ico=0"
set "hed=0"
set "gpd=0"
set "col=1"
set "snu=0"
set "sac=0"
set "scr=0"
set "ssz=0"

:: Display help if requested
if "%1"=="--help" goto display_help
if "%1"=="/?" goto display_help

:: Parse options
:parse_options
if "%1"=="" goto :end_parse_options
if /i "%1"=="-a" set "dot=1"
if /i "%1"=="-h" set "hru=1"
if /i "%1"=="-g" set "git=0"
if /i "%1"=="-t" set "snu=1"
if /i "%1"=="-u" set "sac=1"
if /i "%1"=="-c" set "scr=1"
if /i "%1"=="-S" set "ssz=1"
if /i "%1"=="--icons" set "ico=1"
if /i "%1"=="--color=never" set "col=0"
shift
goto :parse_options

:end_parse_options

:: Build eza command with options
set "eza_opts="
if %dot% equ 1 set "eza_opts=-a"
if %snu% equ 1 set "eza_opts=!eza_opts! -s modified"
if %sac% equ 1 set "eza_opts=!eza_opts! -us accessed"
if %scr% equ 1 set "eza_opts=!eza_opts! -Us created"
if %ssz% equ 1 set "eza_opts=!eza_opts! -s size"
if %hru% equ 1 set "eza_opts=!eza_opts! -B"
if %meb% equ 1 set "eza_opts=!eza_opts! -b"
if %fgp% equ 1 set "eza_opts=!eza_opts! -g"
if %lnk% equ 1 set "eza_opts=!eza_opts! -H"
if %git% equ 1 (
  git rev-parse --is-inside-work-tree >nul 2>nul
  if !errorlevel! equ 0 set "eza_opts=%eza_opts% --git"
)
if %ico% equ 1 set "eza_opts=!eza_opts! --icons"
if %hed% equ 1 set "eza_opts=!eza_opts! -h"
if %gpd% equ 1 set "eza_opts=!eza_opts! --group-directories-first"
if %col% equ 1 set "eza_opts=!eza_opts! --color=always"
if %col% equ 0 set "eza_opts=!eza_opts! --color=never"

:: Run eza command
eza.exe --no-quotes %eza_opts% %*
exit /b 0

:display_help
echo Usage: ls [options]
echo.
echo Options:
echo   -a             all
echo   -l             long listing format
echo   -h             human readable file sizes
echo   -g             do not show file git status
echo   --icons        show icons
echo   --color=never  disable color output
echo   --help         display this help message
echo.
exit /b 0
