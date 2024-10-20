# Jason Gomez - June 2024
# Problem 1: When installing Vim for Windows using winget it's not added
#            to $PATH so it cannot easily be used from the command line.
# Problem 2: The path to the Vim executables keeps changing as the
#            version number is part of the path.
# Solution:  This script makes a persistent symlink to the latest installed
#            version of Vim for Windows and adds it to $PATH. Re-run the
#            script when a new version of Vim is installed.

# Get all Vim directories and sort them by version number
$vimDirs = Get-ChildItem -Path "C:\Program Files\Vim\" -Directory |
    Where-Object { $_.Name -match '^vim(\d+)$' } |
    Sort-Object { [int]($_.Name -replace 'vim', '') } -Descending

# Select the latest version
$latestVim = $vimDirs[0].FullName

# Define the symbolic link path
$symLinkPath = "C:\Program Files\Vim\Current"

# Create the symbolic link if it doesn't exist or if it's not pointing to the latest version
if (-not (Test-Path $symLinkPath) -or (Get-Item $symLinkPath).Target -ne $latestVim) {
    # Remove existing symbolic link if it exists
    if (Test-Path $symLinkPath) {
        Remove-Item $symLinkPath -Force -Recurse
    }

    # Create new symbolic link to the latest Vim version
    New-Item -ItemType SymbolicLink -Path $symLinkPath -Target $latestVim | Out-Null
    Write-Host "Vim symlink created"
}

# Get current $PATH
$path = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)

# Add vim to $PATH if necessary
if ($path -notlike "*$symLinkPath*") {
    # Append the symLinkPath to $PATH if it's not already there
    $newPath = "$path;$symLinkPath"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::User)
    Write-Host "Vim added to path"
} else {
    Write-Host "Vim path is already in the system PATH"
}
