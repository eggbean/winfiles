@echo off

set PATH=%USERPROFILE%\winfiles\scripts;%USERPROFILE%\winfiles\bin;%PATH%

doskey sudo=gsudo $*
doskey ls=eza-wrapper.cmd $*
doskey ll=eza-wrapper.cmd -l $*
doskey vi=vim $*
doskey vimdiff=vim -d $*
doskey props=GDProps.exe $*
doskey take=mkdir $1 $T cd $1
doskey qb="C:\Program Files\qutebrowser\qutebrowser.exe" $*
doskey qutebrowser="C:\Program Files\qutebrowser\qutebrowser.exe" $*
doskey copyq=copyq-wrapper.cmd $*
doskey google=explorer "https://www.google.com/search?q=$*"
doskey vihosts=sudo gvim C:\Windows\System32\Drivers\etc\hosts
doskey startmenu=pushd %APPDATA%\Microsoft\Windows\Start Menu\Programs

:: The rest of the aliases depend on Scoop being installed
if not exist "%SCOOP%\shims\scoop.cmd" (
    echo scoop not installed
    goto :HomeStart
)
doskey scoop=scoop-wrapper.cmd $*
doskey cd=cdd.cmd $*
doskey date=%SCOOP%\shims\date.exe $*
doskey find=%SCOOP%\shims\find.exe $*
doskey cat=ccat $*
doskey cp=cp -i $*
doskey mv=mv -i $*
doskey rm=rm -I $*
doskey br=broot $*
doskey time=timecmd $*
doskey tree=tre.exe $*
doskey wget=wget2 $*
doskey wol=WakeMeOnLan.exe $*
doskey z=z   :: These are just so that these zoxide commands don't
doskey zi=zi :: get highlighted in red in the interactive shell
doskey za=zoxide add $*
doskey screenoff=nircmd monitor async_off
doskey battery=batteryinfoview

:HomeStart
if %CD%==C:\Windows\System32 (
    cdd %USERPROFILE%
    cdd --reset >nul 2>&1
)

if %CD%==%LOCALAPPDATA%\Microsoft\WindowsApps (
    goto :processCD
) else (
    if %CD%==%LOCALAPPDATA%\PowerToys (
        goto :processCD
    )
)

goto :eof

:processCD
cls
fastfetch -l Windows
cdd %USERPROFILE% & cdd --reset >nul 2>&1
goto :eof
