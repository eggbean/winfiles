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

:: Parse options
:parse_options
if "%1"=="" goto :end_parse_options
if /i "%1"=="-a" set "dot=1" & set "hru=0"
if /i "%1"=="-l" set "hed=1"
if /i "%1"=="-h" set "hru=1" & set "meb=0"
if /i "%1"=="-g" set "git=0"
if /i "%1"=="--icons" set "ico=1"
if /i "%1"=="--color=never" set "col=0"
shift
goto :parse_options

:end_parse_options

:: Build eza command with options
set "eza_opts="
if %dot% equ 1 set "eza_opts=-a"
if %hru% equ 1 set "eza_opts=!eza_opts! -h"
if %meb% equ 1 set "eza_opts=!eza_opts! -b"
if %fgp% equ 1 set "eza_opts=!eza_opts! -g"
if %lnk% equ 1 set "eza_opts=!eza_opts! -H"
if %git% equ 1 (
  git rev-parse --is-inside-work-tree >nul 2>nul
  if !errorlevel! equ 0 set "eza_opts=!eza_opts! --git"
)
if %ico% equ 1 set "eza_opts=!eza_opts! --icons"
if %hed% equ 1 set "eza_opts=!eza_opts! -h"
if %gpd% equ 1 set "eza_opts=!eza_opts! --group-directories-first"
if %col% equ 1 set "eza_opts=!eza_opts! --color=always"
if %col% equ 0 set "eza_opts=!eza_opts! --color=never"

:: Run eza command
eza.exe %eza_opts% %*

:end
