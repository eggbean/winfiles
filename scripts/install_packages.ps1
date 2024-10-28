# Install packages using winget

# Ensure the script is run with administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-Not $isAdmin) {
    Write-Error "This script needs to be run as Administrator."
    exit 1
}

# Install essential packages
winget install --source winget -e --id Git.Git --override "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=git_options.ini"
winget install --source winget -e --id Google.Chrome
winget install --source winget -e --id Microsoft.PowerShell
winget install --source winget -e --id Microsoft.VCRedist.2015+.x64
winget install --source winget -e --id Microsoft.VCRedist.2015+.x86
winget install --source winget -e --id Microsoft.WindowsTerminal
winget install --source winget -e --id Mozilla.Firefox
winget install --source winget -e --id Mythicsoft.AgentRansack
winget install --source winget -e --id Notion.Notion --no-upgrade
winget install --source winget -e --id Python.Python.3.13
winget install --source winget -e --id SomePythonThings.WingetUIStore --override "/SP /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NoAutoStart /ALLUSERS /LANG=english"
winget install --source winget -e --id WinDirStat.WinDirStat
winget install --source winget -e --id chrisant996.Clink
winget install --source winget -e --id gerardog.gsudo
winget install --source winget -e --id hluk.CopyQ
winget install --source winget -e --id qutebrowser.qutebrowser -l "C:\Program Files\qutebrowser"
winget install --source winget -e --id vim.vim
winget install --source winget -e --id wez.wezterm

# Install software for desktop computers
# Check if the chassis type indicates a desktop computer (values between 3 and 7)
$chassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes
if ($chassisType -ge 3 -and $chassisType -le 7 -and $env:USERNAME -ne "vagrant") {
    winget install --source winget -e --id CreativeTechnology.CreativeApp
    winget install --source winget -e --id Dell.DisplayManager -v 1.56.2110
    winget install --source winget -e --id Logitech.OptionsPlus --skip-dependencies
    winget install --source winget -e --id xanderfrangos.twinkletray
}

# Install packages for personal account
if ($env:USERNAME -eq "jason" -or $env:USERNAME -eq "vagrant") {
    winget install --source msstore -e --id 9NKSQGP7F2NH --accept-package-agreements   # WhatsApp
    winget install --source msstore -e --id 9P3JFR0CLLL6 --accept-package-agreements   # mpv (Unofficial)
    winget install --source winget -e --id Amazon.SendToKindle --skip-dependencies
    winget install --source winget -e --id Audacity.Audacity
    winget install --source winget -e --id BrianApps.Sizer
    winget install --source winget -e --id CPUID.CPU-Z
    winget install --source winget -e --id CrystalDewWorld.CrystalDiskInfo
    winget install --source winget -e --id CrystalDewWorld.CrystalDiskMark
    winget install --source winget -e --id Discord.Discord --no-upgrade
    winget install --source winget -e --id GnuPG.Gpg4win
    winget install --source winget -e --id GoLang.Go
    winget install --source winget -e --id Google.CloudSDK
    winget install --source winget -e --id Google.GoogleDrive
    winget install --source winget -e --id Hashicorp.Vagrant
    winget install --source winget -e --id LocalSend.LocalSend
    winget install --source winget -e --id M2Team.NanaZip
    winget install --source winget -e --id Microsoft.PowerToys --accept-source-agreements -h --disable-interactivity --accept-package-agreements
    winget install --source winget -e --id NGWIN.PicPick
    winget install --source winget -e --id NathanBeals.WinSSH-Pageant
    winget install --source winget -e --id Nikkho.FileOptimizer
    winget install --source winget -e --id OpenWhisperSystems.Signal
    winget install --source winget -e --id Pushbullet.Pushbullet
    winget install --source winget -e --id REALiX.HWiNFO
    winget install --source winget -e --id RustemMussabekov.Raindrop
    winget install --source winget -e --id Samsung.DeX
    winget install --source winget -e --id SergeySerkov.TagScanner
    winget install --source winget -e --id SlackTechnologies.Slack
    winget install --source winget -e --id Soulseek.SoulseekQt
    winget install --source winget -e --id SumatraPDF.SumatraPDF
    winget install --source winget -e --id VirusTotal.VirusTotalUploader
    winget install --source winget -e --id WinMerge.WinMerge
    winget install --source winget -e --id WinSCP.WinSCP
    winget install --source winget -e --id WiresharkFoundation.Wireshark
    winget install --source winget -e --id Xanashi.Icaros
    winget install --source winget -e --id XnSoft.XnViewMP
    winget install --source winget -e --id ente-io.auth-desktop --skip-dependencies
    winget install --source winget -e --id flyingpie.windows-terminal-quake   # actually for wezterm
    winget install --source winget -e --id qBittorrent.qBittorrent
}
