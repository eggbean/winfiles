@echo off

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
echo IconResource=%USERPROFILE%\winfiles\icons\Folder11-Ico\ico\microsoft_windows_11.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd

:: Set vimfiles folder icon
pushd %USERPROFILE%\vimfiles
del /a ash desktop.ini
echo [.ShellClassInfo] > desktop.ini
echo IconResource=%USERPROFILE%\winfiles\icons\Folder11-Ico\ico\vimfiles.ico,0 >> desktop.ini
attrib +a +s +h desktop.ini
popd
