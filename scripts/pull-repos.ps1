# Pull repos
$REPO_DIRS = @(
    "$env:USERPROFILE\Documents\Chrome Extensions\bypass-paywalls-chrome-clean",
    "$env:USERPROFILE\Documents\Chrome Extensions\bypass-paywalls-chrome-master",
    "$env:USERPROFILE\winfiles\Settings\clink-completions",
    "$env:USERPROFILE\winfiles\Settings\clink-gizmos",
    "$env:USERPROFILE\winfiles",
    "$env:USERPROFILE\.dotfiles"
)

foreach ($REPO_DIR in $REPO_DIRS) {
    if (Test-Path -Path $REPO_DIR -PathType Container) {
        # Capture the current stash list
        $STASH_LIST_BEFORE = git -C $REPO_DIR stash list

        # Check for changes and stash if needed
        $status = git -C $REPO_DIR status --porcelain
        if ($status) {
            Write-Host "Changes detected in $REPO_DIR. Stashing..."
            git -C $REPO_DIR stash
            $STASHED = $true
        }

        Write-Host "Pulling repository $REPO_DIR..."
        git -C $REPO_DIR pull --no-ff

        # Capture the current stash list after the potential stash
        $STASH_LIST_AFTER = git -C $REPO_DIR stash list

        # Determine if a new stash was created by comparing stash lists
        if ($STASH_LIST_BEFORE -ne $STASH_LIST_AFTER) {
            if ($STASHED) {
                Write-Host "Popping stash in $REPO_DIR..."
                git -C $REPO_DIR stash pop
            }
        }

        Write-Host "Done with $REPO_DIR."
    }
}
