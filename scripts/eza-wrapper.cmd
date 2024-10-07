@echo off
:: eza wrapper script - work in progress

setlocal enabledelayedexpansion

:: Default options
set "dot=0"
set "hru=0"
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
set "lng=0"

:: Display help if requested
if "%~1" == "--help" goto display_help
if "%~1" == "/?" goto display_help

:: Parse options
:parse_options
if "%~1" == "" goto :end_parse_options

:: Handling combined short options (e.g., -lah)
set "opt_str=%~1"
if "!opt_str:~0,1!" == "-" (
  set "opt_str=!opt_str:~1!"
  for /l %%i in (0,1,31) do (
    set "opt_char=!opt_str:~%%i,1!"
    if "!opt_char!" == "" goto :shift_and_parse
    if "!opt_char!" == "a" set "dot=1"
    if "!opt_char!" == "l" set "lng=1"
    if "!opt_char!" == "h" set "hru=1"
    if "!opt_char!" == "g" set "git=0"
    if "!opt_char!" == "S" set "ssz=1"
    if "!opt_char!" == "t" set "snu=1"
    if "!opt_char!" == "u" set "sac=1"
  )
  :shift_and_parse
  shift
  goto :parse_options
)

:: Parsing individual long options
if /i "%~1" == "--icons" set "ico=1"
if /i "%~1" == "--color=never" set "col=0"
if /i "%~1" == "--color=always" set "col=1"
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
if %hru% equ 1 set "eza_opts=!eza_opts! -h"
if %meb% equ 1 set "eza_opts=!eza_opts! -b"
if %fgp% equ 1 set "eza_opts=!eza_opts! -g"
if %lnk% equ 1 set "eza_opts=!eza_opts! -H"
if %lng% equ 1 set "eza_opts=!eza_opts! -l"
if %git% equ 1 (
  git rev-parse --is-inside-work-tree >nul 2>nul
  if !errorlevel! equ 0 set "eza_opts=!eza_opts! --git"
)
if %ico% equ 1 set "eza_opts=!eza_opts! --icons"
if %gpd% equ 1 set "eza_opts=!eza_opts! --group-directories-first"
if %col% equ 1 set "eza_opts=!eza_opts! --color=always"
if %col% equ 0 set "eza_opts=!eza_opts! --color=never"

:: Run eza command with any remaining arguments
set "args=%*"
eza.exe --no-quotes %eza_opts% %args%
exit /b 0

:display_help
echo Usage: ls [options]
echo.
echo Options:
echo   -a             show all files, including hidden
echo   -l             long listing format
echo   -h             human readable file sizes
echo   -g             do not show Git status
echo   -t             sort by modification time
echo   -S             sort by size
echo   -u             sort by access time
echo   --icons        show icons
echo   --color=never  disable color output
echo   --help         display this help message
echo.
exit /b 0
