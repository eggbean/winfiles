@echo off

:: Convenience wrapper to make it easier to run from cmd.exe

powershell -File "%~dp0bootstrap.ps1" %*
