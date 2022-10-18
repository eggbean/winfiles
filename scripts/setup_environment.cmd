@echo off

:: Sets symlinks in AppData for clink settings and dotfiles in repository
:: and hides dotfiles and dotdirectories in %USERPROFILE% and winfiles

if not exist %USERPROFILE%\AppData\Local\clink (
    mkdir %USERPROFILE%\AppData\Local\clink
)
if exist %USERPROFILE%\AppData\Local\clink\clink_start.cmd (
    del %USERPROFILE%\AppData\Local\clink\clink_start.cmd
)
mklink %USERPROFILE%\AppData\Local\clink\clink_start.cmd %USERPROFILE%\winfiles\scripts\clink_start.cmd
if exist %USERPROFILE%\AppData\Local\clink\clink_settings (
    del %USERPROFILE%\AppData\Local\clink\clink_settings
)
mklink %USERPROFILE%\AppData\Local\clink\clink_settings %USERPROFILE%\winfiles\Settings\clink_settings

if exist %USERPROFILE%\AppData\Local\clink\_inputrc (
    del %USERPROFILE%\AppData\Local\clink\_inputrc
)
mklink %USERPROFILE%\AppData\Local\clink\_inputrc %USERPROFILE%\winfiles\Settings\_inputrc

if not exist %USERPROFILE%\.config (
    mklink /d %USERPROFILE%\.config %USERPROFILE%\winfiles\Settings\.config
)
attrib /l +h %USERPROFILE%\.config

if exist %USERPROFILE%\.profile (
    del /a %USERPROFILE%\.profile
)
mklink %USERPROFILE%\.profile %USERPROFILE%\winfiles\Settings\.profile
attrib /l +h %USERPROFILE%\.profile

for /f %%D in ('dir /b /a:-h %USERPROFILE%\.*') do attrib +h %USERPROFILE%\%%D
for /f %%E in ('dir /b /a:-h %USERPROFILE%\winfiles\.*') do attrib +h %USERPROFILE%\winfiles\%%E
