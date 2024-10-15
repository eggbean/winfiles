# Retrieve GPG private key from Dashlane if not present in GPG keyring
try {
    $env:GNUPGHOME = "$env:APPDATA\gnupg"
    $gpgKeysPresent = gpg --list-secret-keys
    if ([string]::IsNullOrWhiteSpace($gpgKeysPresent)) {
        throw "No GPG secret keys found"
    }
}
catch {
    $gpgKeyPath = Join-Path -Path $env:TEMP -ChildPath "temp_gpg_key.asc"
    $dcliPath = Join-Path -Path $env:USERPROFILE -ChildPath "winfiles\bin\dcli.exe"
    $gpgPath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath "GnuPG\bin\gpg.exe"

    Write-Host 'Enter credentials for Dashlane:'
    & $dcliPath sync
    & $dcliPath note gpg_private_key | Set-Content -Path $gpgKeyPath
    echo y | & $dcliPath logout

    Write-Host "Importing GPG key. You will be prompted for the passphrase."
    & $gpgPath --import $gpgKeyPath

    Remove-Item $gpgKeyPath -ErrorAction SilentlyContinue
}
