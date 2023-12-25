@echo off
rem Run the script as administrator
cd /d %~dp0
for /f "tokens=3 delims=\ " %%i in ('whoami /groups^|find "Mandatory"') do set LEVEL=%%i
if NOT "%LEVEL%"=="High" (
@powershell -NoProfile -ExecutionPolicy RemoteSigned -Command "Start-Process \"%~f0\" -Verb runas"
exit
)

schtasks /delete /tn "SylphyHorn Startup" /F
