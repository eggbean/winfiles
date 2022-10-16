@echo off

:: Sets icons for various folders

:: Fix icons for Creative Cloud sync
pushd "C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\sibres\CloudSync"
copy "%USERPROFILE%\winfiles\icons\my_icons\cloud_fld_w10.ico" .
copy "%USERPROFILE%\winfiles\icons\my_icons\cloud_fld_w10_offline.ico" .
copy "%USERPROFILE%\winfiles\icons\my_icons\shared_fld_w10.ico" .
copy "%USERPROFILE%\winfiles\icons\my_icons\RO_shared_fld_w10.ico" .
popd

:: Set winfiles folder icon
pushd %USERPROFILE%\winfiles
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\microsoft_windows_11.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set vimfiles folder icon
pushd %USERPROFILE%\vimfiles
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\vimfiles.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set google drive folder icon
pushd %USERPROFILE%\"Google Drive"
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo InfoTip=Your Google Drive folder contains files that you're syncing with Google. >> desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\google_drive.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set icloud drive folder icon
pushd %USERPROFILE%\iCloudDrive
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo LocalizedResourceName=iCloud Drive >> desktop.ini
echo InfoTip=iCloud Drive >> desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\iCloud Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set bin folder icon
pushd %USERPROFILE%\winfiles\bin
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\bat.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set icons folder icon
pushd %USERPROFILE%\winfiles\icons
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Apps Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set my_icons folder icon
pushd %USERPROFILE%\winfiles\icons\my_icons
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Apps Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set installers folder icon
pushd %USERPROFILE%\winfiles\Installers
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Software Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set reg files folder icon
pushd %USERPROFILE%\winfiles\reg
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Registry Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set scripts folder icon
pushd %USERPROFILE%\winfiles\scripts
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\VBS Folder.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set settings folder icon
pushd %USERPROFILE%\winfiles\Settings
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set windows terminal settings folder icon
pushd %USERPROFILE%\winfiles\Windows_Terminal
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\my_icons\Batch Folder Icon.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd
