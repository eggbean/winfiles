# PowerShell script to install scoop for multi-user and packages.
# If re-run when scoop is already installed, any additional packages
# are installed and shims are reset in order of the package list.
# I prefer to keep user and global packages as the same, so there's
# a minor inconvenience in some situations where packages will
# be listed twice with global commands.

# Test if Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ Write-Host "This script requires administrative privileges."; Exit }

# Check if scoop is installed
Function Test-ScoopInstalled {
    $scoopPath = "C:\ProgramData\Scoop"
    return (Test-Path $scoopPath)
}
$initiallyInstalled = Test-ScoopInstalled

# Install scoop for all users if not installed
if (-NOT $initiallyInstalled) {
    $env:SCOOP = "C:\ProgramData\Scoop"
    $env:SCOOP_GLOBAL = "C:\ProgramData\Scoop"
    [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'Machine')
    [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    icacls $env:SCOOP /grant "Users:(OI)(CI)F" /T

    # Install aria2c for multi-connection downloads
    scoop install aria2 -u -g
    scoop config aria2-warning-enabled false

    # Install buckets
    scoop bucket add extras
    scoop bucket add nirsoft
    scoop bucket add sysinternals
}

# Install packages
$packages = @(
    'busybox'
    'uutils-coreutils'
    'bat'
    'bind'
    'broot'
    'ccat'
    'charm-gum'
    'croc'
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
    'geoipupdate'
    'gh'
    'git-crypt'
    'glow'
    'grep'
    'jq'
    'less'
    'lf'
    'mediainfo'
    'minio-client'
    'monolith'
    'nirsoft/batteryinfoview'
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
    'sysinternals/handle'
    'sysinternals/pstools'
    'sysinternals/regjump'
    'sysinternals/sdelete'
    'sysinternals/shellrunas'
    'time'
    'tlrc'
    'tre-command'
    'unzip'
    'wakemeonlan'
    'wget2'
    'whois'
    'xmllint'
    'zoxide'
)

foreach ($package in $packages) {
    scoop install $package -u -g
}

# Reset shims in order of package list
# if scoop was already installed
if ($initiallyInstalled) {
    scoop update * -g
    foreach ($package in $packages) {
        scoop reset $package
    }
}

# Delete irrelevant/unwanted shims from busybox
$del_shims = @(
    'ar'
    'ash'
    'bash'
    'bunzip2'
    'busybox'
    'bzcat'
    'bzip2'
    'cal'
    'chmod'
    'clear'
    'cpio'
    'dc'
    'dpkg'
    'dpkg-deb'
    'ed'
    'fsync'
    'ftpget'
    'ftpput'
    'getopt'
    'groups'
    'gunzip'
    'gzip'
    'hd'
    'hexdump'
    'httpd'
    'iconv'
    'id'
    'kill'
    'killall'
    'logname'
    'lzcat'
    'lzma'
    'lzop'
    'lzopcat'
    'man'
    'pgrep'
    'pidof'
    'pipe_progress'
    'pkill'
    'ps'
    'reset'
    'rpm'
    'rpm2cpio'
    'sh'
    'ssl_client'
    'su'
    'ttysize'
    'uncompress'
    'unlzma'
    'unlzop'
    'unxz'
    'usleep'
    'uudecode'
    'uuencode'
    'vi'
    'which'
    'xxd'
    'xz'
    'xzcat'
    'zcat'
)

foreach ($shim in $del_shims) {
    scoop shim rm $shim -g
}
