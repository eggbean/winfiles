# git crypt: unlock repository if locked
$env:GNUPGHOME = "$env:APPDATA\gnupg"
function Unlock-Repository {
    param (
        [string]$repo
    )

    if (Test-Path $repo) {
        Push-Location $repo
        try {
            if (Test-Path -Path $repo -PathType Container) {
                # Check if the repository is unlocked by testing for git-crypt smudge filter
                git config -f "$repo\.git\config" --get filter.git-crypt.smudge | Out-Null  # Run git config and suppress output

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Repository '$repo' is already unlocked. Skipping unlock."
                } else {
                    Write-Output "Repository '$repo' is locked. Proceeding with unlock..."

                    # Capture the stash count before making any changes
                    $stashCountBefore = (git -C $repo stash list).Count

                    # Check for changes and stash if needed
                    $status = git -C $repo status --porcelain
                    $stashed = $false

                    if ($status) {
                        Write-Host "Changes detected in $repo. Stashing..."
                        git -C $repo stash
                        $stashed = $true
                    }

                    Write-Output "Attempting to unlock git crypt in '$repo'..."
                    git crypt unlock

                    # Check if the unlock was successful
                    if ($LASTEXITCODE -eq 0) {
                        Write-Output "Unlocked successfully."
                    } else {
                        Write-Error "Failed to unlock git crypt in '$repo'."
                    }

                    # Capture the stash count after unlocking
                    $stashCountAfter = (git -C $repo stash list).Count

                    # Check if a new stash was created and pop it back if necessary
                    if ($stashed -and ($stashCountBefore -lt $stashCountAfter)) {
                        Write-Host "Popping stash in $repo..."
                        git -C $repo stash pop
                    }
                }
            }
        } catch {
            Write-Error "Error unlocking git crypt in '$repo': $_"
        } finally {
            Pop-Location
        }
    } else {
        Write-Error "Error: Directory '$repo' does not exist."
    }
}
