# Install packages using winget

# Check if the script is running with admin privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-Not $isAdmin) {
    Write-Output "Not admin/elevated"
    exit 1
}

# Install essential packages
winget install -e --id Git.Git --override "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=git_options.ini"
winget install -e --id Google.Chrome
winget install -e --id Microsoft.PowerShell
winget install -e --id Microsoft.VCRedist.2015+.x64
winget install -e --id Microsoft.VCRedist.2015+.x86
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Mozilla.Firefox
winget install -e --id Mythicsoft.AgentRansack
winget install -e --id NGWIN.PicPick
winget install -e --id Notion.Notion --no-upgrade
winget install -e --id SomePythonThings.WingetUIStore --override "/SP /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NoAutoStart /ALLUSERS /LANG=english"
winget install -e --id WinDirStat.WinDirStat --include-unknown
winget install -e --id XnSoft.XnViewMP
winget install -e --id chrisant996.Clink
winget install -e --id flyingpie.windows-terminal-quake
winget install -e --id gerardog.gsudo
winget install -e --id hluk.CopyQ
winget install -e --id qutebrowser.qutebrowser -l "C:\Program Files\qutebrowser"
winget install -e --id vim.vim
winget install -e --id wez.wezterm


# Install software for desktop computers
# Check if the chassis type indicates a desktop computer (values between 3 and 7)
$chassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes
if ($chassisType -ge 3 -and $chassisType -le 7) {
    winget install -e --id CreativeTechnology.CreativeApp
    winget install -e --id CrystalDewWorld.CrystalDiskInfo
    winget install -e --id CrystalDewWorld.CrystalDiskMark
    winget install -e --id Dell.DisplayManager -v 1.56.2110
    winget install -e --id Logitech.OptionsPlus
    winget install -e --id xanderfrangos.twinkletray
}

# Install packages for personal account
if ($env:USERNAME -eq "jason" -or $env:USERNAME -eq "vagrant") {
    winget install -e --id 9NKSQGP7F2NH --accept-package-agreements   # WhatsApp
    winget install -e --id 9P3JFR0CLLL6 --accept-package-agreements   # mpv (Unofficial)
    winget install -e --id Amazon.SendToKindle --skip-dependencies
    winget install -e --id Audacity.Audacity
    winget install -e --id BrianApps.Sizer
    winget install -e --id CPUID.CPU-Z
    winget install -e --id Discord.Discord --no-upgrade
    winget install -e --id GnuPG.Gpg4win
    winget install -e --id Google.GoogleDrive
    winget install -e --id Hashicorp.Vagrant
    winget install -e --id LocalSend.LocalSend
    winget install -e --id M2Team.NanaZip
    winget install -e --id Microsoft.PowerToys --accept-source-agreements -h --disable-interactivity --accept-package-agreements
    winget install -e --id NathanBeals.WinSSH-Pageant
    winget install -e --id Nikkho.FileOptimizer
    winget install -e --id OpenWhisperSystems.Signal
    winget install -e --id Oracle.VirtualBox --skip-dependencies -v 7.0.20   # Hold version for vagrant compatibility
    winget install -e --id REALiX.HWiNFO
    winget install -e --id RustemMussabekov.Raindrop
    winget install -e --id Samsung.DeX
    winget install -e --id SergeySerkov.TagScanner
    winget install -e --id SlackTechnologies.Slack
    winget install -e --id Soulseek.SoulseekQt
    winget install -e --id SumatraPDF.SumatraPDF
    winget install -e --id VirusTotal.VirusTotalUploader
    winget install -e --id WinMerge.WinMerge
    winget install -e --id WinSCP.WinSCP
    winget install -e --id WiresharkFoundation.Wireshark
    winget install -e --id Xanashi.Icaros --source winget
    winget install -e --id ente-io.auth-desktop --skip-dependencies
    winget install -e --id qBittorrent.qBittorrent
}
