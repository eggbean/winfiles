# PowerShell script to install scoop for multi-user and packages.
# If scoop is already installed, any additional packages are installed
# and shims are reset in order of the package list.

# Test if Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ Write-Host "This script requires administrative privileges."; Exit }

# Check if scoop is installed
Function Test-ScoopInstalled {
    $scoopExists = Get-Command scoop -ErrorAction SilentlyContinue
    return $scoopExists -ne $null
}

# Install scoop for all users if not installed
if (-NOT (Test-ScoopInstalled)) {
    $SCOOP = "C:\ProgramData\scoop"
    [Environment]::SetEnvironmentVariable("SCOOP", "C:\ProgramData\scoop", "Machine")
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    icacls $SCOOP /grant "Users:(OI)(CI)F" /T

    # Install aria2c for multi-connection downloads
    scoop install aria2 -u -g
    scoop config aria2-warning-enabled false

    # Install buckets
    scoop bucket add extras
    scoop bucket add nirsoft
    scoop bucket add sysinternals
}

# Update scoop
scoop update * -g

# Install packages
$packages = @(
    'uutils-coreutils'
    'bat'
    'bind'
    'broot'
    'ccat'
    'charm-gum'
    'curl'
    'delta'
    'diffutils'
    'dos2unix'
    'dust'
    'eza'
    'fastfetch'
    'fd'
    'ffmpeg'
    'file'
    'findutils'
    'fzf'
    'gawk'
    'gh'
    'git-crypt'
    'glow'
    'grep'
    'iperf3'
    'jq'
    'less'
    'lf'
    'mediainfo'
    'minio-client'
    'monolith'
    'nirsoft/browsinghistoryview'
    'nirsoft/filetypesman'
    'nirsoft/hotkeyslist'
    'nirsoft/mobilefilesearch'
    'nirsoft/nircmd'
    'nirsoft/regscanner'
    'nirsoft/shellmenunew'
    'nirsoft/shellmenuview'
    'nirsoft/usbdeview'
    'rclone'
    'ripgrep'
    'scoop-search'
    'sed'
    'sfsu'
    'spotify-tui'
    'starship'
    'sysinternals/autoruns'
    'sysinternals/psexec'
    'sysinternals/psshutdown'
    'sysinternals/regjump'
    'sysinternals/sdelete'
    'sysinternals/shellrunas'
    'tlrc'
    'tre-command'
    'unzip'
    'wakemeonlan'
    'wget'
    'whois'
    'zoxide'
)

foreach ($package in $packages) {
    scoop install $package -u -g
}

# Reset shims in order of package list
# if scoop was already installed
if (Test-ScoopInstalled) {
    foreach ($package in $packages) {
        scoop reset $package
    }
}
