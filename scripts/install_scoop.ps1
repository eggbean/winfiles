# PowerShell script to install scoop for multi-user and packages

# Test if Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ Write-Host "This script requires administrative privileges."; Exit }

# Install scoop
$SCOOP = "C:\ProgramData\scoop"
[Environment]::SetEnvironmentVariable("SCOOP", "C:\ProgramData\scoop", "Machine")
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
scoop update * -g
icacls $SCOOP /grant "Users:(OI)(CI)F" /T

# Install aria2c for multi-connection downloads
scoop install aria2 -u -g
scoop config aria2-warning-enabled false

# Install buckets
scoop bucket add extras
scoop bucket add nirsoft
scoop bucket add sysinternals

# Install packages
$packages = @(
    'busybox'
    'coreutils'
    'uutils-coreutils'
    'bat'
    'bind'
    'broot'
    'curl'
    'delta'
    'dos2unix'
    'dust'
    'eza'
    'fastfetch'
    'fd'
    'file'
    'findutils'
    'fzf'
    'git-crypt'
    'glow'
    'grep'
    'iperf3'
    'jq'
    'less'
    'lf'
    'mediainfo'
    'monolith'
    'netcat'
    'nirsoft/ShellMenuNew'
    'nirsoft/ShellMenuview'
    'nirsoft/filetypesman'
    'nirsoft/nircmd'
    'rclone'
    'ripgrep'
    'sed'
    'starship'
    'sysinternals/autoruns'
    'sysinternals/psexec'
    'sysinternals/psshutdown'
    'sysinternals/regjump'
    'sysinternals/sdelete'
    'sysinternals/shellrunas'
    'sysinternals/sync'
    'touch'
    'tre'
    'wakemeonlan'
    'wget'
    'whois'
    'zoxide'
)

($i = 0; $i -lt $packages.Length; $i++) {
    $package = $packages[$i]
    scoop install $package -u -g
}
