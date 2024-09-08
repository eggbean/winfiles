@echo off

if "%1" == "search" goto search_subroutine
if "%1" == "app" goto sfsu_subroutine
if "%1" == "bucket" goto sfsu_subroutine
if "%1" == "cache" goto sfsu_subroutine
if "%1" == "cat" goto sfsu_subroutine
if "%1" == "checkup" goto sfsu_subroutine
if "%1" == "depends" goto sfsu_subroutine
if "%1" == "describe" goto sfsu_subroutine
if "%1" == "download" goto sfsu_subroutine
if "%1" == "export" goto sfsu_subroutine
if "%1" == "home" goto sfsu_subroutine
if "%1" == "info" goto sfsu_subroutine
if "%1" == "list" goto sfsu_subroutine
if "%1" == "outdated" goto sfsu_subroutine
if "%1" == "scan" goto sfsu_subroutine
if "%1" == "status" goto sfsu_subroutine
if "%1" == "unused-buckets" goto sfsu_subroutine
if "%1" == "update" goto sfsu_subroutine
powershell scoop.ps1 %*
goto :EOF

:search_subroutine
set "args=%*"
set "newargs=%args:* =%"
scoop-search.exe %newargs%
goto :EOF

:sfsu_subroutine
set "args=%*"
set "newargs=%args:* =%"
sfsu.exe %1 %newargs%
goto :EOF
