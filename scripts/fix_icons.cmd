@echo off

:: Sets icons for various folders

net session >nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Not admin/elevated
    exit /b 1
)

:: Fix icons for Creative Cloud sync
if exist "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync" (
    pushd "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync"
    copy "%USERPROFILE%\winfiles\icons\my_icons\cloud_fld_w10.ico" .
    copy "%USERPROFILE%\winfiles\icons\my_icons\cloud_fld_w10_offline.ico" .
    copy "%USERPROFILE%\winfiles\icons\my_icons\shared_fld_w10.ico" .
    copy "%USERPROFILE%\winfiles\icons\my_icons\RO_shared_fld_w10.ico" .
    popd
)

:: Set winfiles folder icon
pushd %USERPROFILE%\winfiles
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\microsoft_windows_11.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set google drive folder icon
if exist %USERPROFILE%\"My Drive" (
    pushd %USERPROFILE%\"My Drive"
    del /a ash desktop.ini
    echo [.ShellClassInfo] > desktop.ini
    echo InfoTip=Your Google Drive folder contains files that you're syncing with Google. >> desktop.ini
    echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\google_drive.ico,0 >> desktop.ini
    attrib +a +s +h desktop.ini
    attrib +r %CD%
    popd
)

:: Set icloud drive folder icon
if exist %USERPROFILE%\iCloudDrive (
    pushd %USERPROFILE%\iCloudDrive
    del /a ash desktop.ini
    echo [.ShellClassInfo] > desktop.ini
    echo LocalizedResourceName=iCloud Drive >> desktop.ini
    echo InfoTip=iCloud Drive >> desktop.ini
    echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\iCloud Folder.ico,0 >> desktop.ini
    attrib +a +s +h desktop.ini
    attrib +r %CD%
    popd
)

:: Set bin folder icon
pushd %USERPROFILE%\winfiles\bin
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\bat.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set clink folder icon
pushd %USERPROFILE%\winfiles\Clink
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Batch Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set fonts folder icon
pushd %USERPROFILE%\winfiles\fonts
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\fonts.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set icons folder icon
pushd %USERPROFILE%\winfiles\icons
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Apps Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set my_icons folder icon
pushd %USERPROFILE%\winfiles\icons\my_icons
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Apps Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set reg files folder icon
pushd %USERPROFILE%\winfiles\reg
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Registry Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set scripts folder icon
pushd %USERPROFILE%\winfiles\scripts
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\VBS Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set settings folder icon
pushd %USERPROFILE%\winfiles\Settings
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Batch Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set SylphyHorn folder icon
pushd %USERPROFILE%\winfiles\SylphyHorn
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\Batch Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd

:: Set windows terminal settings folder icon
pushd %USERPROFILE%\winfiles\Windows_Terminal
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%%USERPROFILE%%\winfiles\icons\my_icons\terminal.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
attrib +r %CD%
popd
