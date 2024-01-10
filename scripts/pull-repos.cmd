@echo off
setlocal

call :processRepo "%USERPROFILE%\winfiles"
call :processRepo "%USERPROFILE%\winfiles\Settings\clink-completions"
call :processRepo "%USERPROFILE%\.dotfiles"

goto :eof

:processRepo
set "REPO_DIR=%~1"
set STASHED=0

git -C "%REPO_DIR%" status --porcelain | findstr "^" >nul
if %ERRORLEVEL% == 0 (
    echo Changes detected in %REPO_DIR%. Stashing...
    git -C "%REPO_DIR%" stash
    set STASHED=1
)

echo Pulling repository %REPO_DIR%...
git -C "%REPO_DIR%" pull --no-ff

if %STASHED% == 1 (
    echo Popping stash in %REPO_DIR%...
    git -C "%REPO_DIR%" stash pop
)

echo Done with %REPO_DIR%.
exit /b
