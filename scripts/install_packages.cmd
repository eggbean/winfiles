@echo off

:: Check if admin
net session >nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Not admin/elevated
    exit /b 1
)

:: Install essential packages
winget install -e --id Git.Git
winget install -e --id Google.Chrome
winget install -e --id Logitech.OptionsPlus
winget install -e --id M2Team.NanaZip
winget install -e --id Microsoft.PowerToys
winget install -e --id Microsoft.VCRedist.2015+.x64
winget install -e --id Microsoft.VCRedist.2015+.x86
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Mozilla.Firefox
winget install -e --id Notion.Notion
winget install -e --id SomePythonThings.WingetUIStore --override "/SP /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NoAutoStart /ALLUSERS /LANG=english"
winget install -e --id WinDirStat.WinDirStat --include-unknown
winget install -e --id WinSCP.WinSCP
winget install -e --id chrisant996.Clink
winget install -e --id gerardog.gsudo
winget install -e --id hluk.CopyQ
winget install -e --id qutebrowser.qutebrowser -l "C:\Program Files\qutebrowser"
winget install -e --id vim.vim

:: Install Dell Display Manager on desktop computers
for /f "delims={}" %%i in ('wmic systemenclosure get chassistypes ^| findstr "{"') do @set "chassistype=%%i"`
if %chassistype% GEQ 2 if %chassistype% LEQ 6 (
        winget install -e --id Dell.DisplayManager -v 1.56.2110
        winget install -e --id xanderfrangos.twinkletray
    )
)

    