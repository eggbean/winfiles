# OpenSSH setup script

# Install OpenSSH client
$openSSHInstalled = Get-WindowsCapability -Online |
                    Where-Object { $_.Name -like "OpenSSH.Client*" -and $_.State -eq "Installed" }

if ($null -eq $openSSHInstalled) {
    Add-WindowsCapability -Online -Name OpenSSH.Client
    Write-Host 'OpenSSH Client installed'
}

# Start ssh-agent on system boot
$service = Get-Service -Name ssh-agent
if ($service.StartType -ne 'Automatic') {
    Set-Service -Name ssh-agent -StartupType Automatic
    Write-Host 'ssh-agent startup type set to Automatic'
    $service.Refresh()
}

if ($service.Status -ne 'Running') {
    Start-Service -Name ssh-agent
    Write-Host 'ssh-agent service started'
}

# Get key from Dashlane CLI if not loaded in ssh-agent
try {
    $sshKeysLoaded = ssh-add -l
    if ($sshKeysLoaded -eq "The agent has no identities.") {
        throw "No keys loaded"
    }
}
catch {
    $sshKeyPath = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh\id_ed25519"
    $sshDir = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"

    if (-not (Test-Path -Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir
    }

    dcli sync
    dcli note id_ed25519 | Set-Content -Path $sshKeyPath
    dcli logout

    ssh-add $sshKeyPath
    Remove-Item $sshKeyPath
}