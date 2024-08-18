@echo off

if "%1" == "search" goto search_subroutine
if "%1" == "list" goto sfsu_subroutine
if "%1" == "info" goto sfsu_subroutine
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
