@echo off
setlocal

call :processRepo "%USERPROFILE%\Documents\Chrome Extensions\bypass-paywalls-chrome-clean"
call :processRepo "%USERPROFILE%\Documents\Chrome Extensions\bypass-paywalls-chrome-master"
call :processRepo "%USERPROFILE%\winfiles\Settings\clink-completions"
call :processRepo "%USERPROFILE%\winfiles\Settings\clink-gizmos"
call :processRepo "%USERPROFILE%\winfiles"
call :processRepo "%USERPROFILE%\.dotfiles"

goto :EOF

:processRepo
set "REPO_DIR=%~1"
set STASHED=0

if exist "%REPO_DIR%" (
    :: Capture the current stash list
    for /f "delims=" %%i in ('git -C "%REPO_DIR%" stash list') do set "STASH_LIST_BEFORE=%%i"

    :: Check for changes and stash if needed
    git -C "%REPO_DIR%" status --porcelain | findstr "^" >nul
    if %ERRORLEVEL% == 0 (
        echo Changes detected in %REPO_DIR%. Stashing...
        git -C "%REPO_DIR%" stash
        set STASHED=1
    )

    echo Pulling repository %REPO_DIR%...
    git -C "%REPO_DIR%" pull --no-ff

    :: Capture the current stash list after the potential stash
    for /f "delims=" %%i in ('git -C "%REPO_DIR%" stash list') do set "STASH_LIST_AFTER=%%i"

    :: Determine if a new stash was created by comparing stash lists
    if "%STASH_LIST_BEFORE%" neq "%STASH_LIST_AFTER%" (
        if %STASHED% == 1 (
            echo Popping stash in %REPO_DIR%...
            git -C "%REPO_DIR%" stash pop
        )
    )

    echo Done with %REPO_DIR%.
)

exit /b
