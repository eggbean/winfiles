# Pull repos
$REPO_DIRS = @(
    "$env:USERPROFILE\Documents\Chrome Extensions\bypass-paywalls-chrome-clean",
    "$env:USERPROFILE\Documents\Chrome Extensions\bypass-paywalls-chrome-master",
    "$env:USERPROFILE\winfiles\Clink\clink-completions",
    "$env:USERPROFILE\winfiles\Clink\clink-gizmos",
    "$env:USERPROFILE\winfiles",
    "$env:USERPROFILE\.dotfiles"
    "$env:USERPROFILE\.dotfiles-complete"
)

foreach ($REPO_DIR in $REPO_DIRS) {
    if (Test-Path -Path $REPO_DIR -PathType Container) {

        Write-Host "Pulling repository $REPO_DIR..."
        git -C $REPO_DIR pull --autostash --no-ff

        Write-Host "Done with $REPO_DIR."
    }
}
