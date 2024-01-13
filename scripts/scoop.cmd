@echo off

if "%1" == "search" (
    call :search_subroutine %*
) else (
    powershell scoop.ps1 %*
)
goto :eof

:search_subroutine
set "args=%*"
set "newargs=%args:* =%"
scoop-search.exe %newargs%
goto :eof
