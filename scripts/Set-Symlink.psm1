function Set-Symlink {
    param (
        [string]$Link,
        [string]$Target
    )

    # Check if the link exists
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        # Check if the link is already a symlink
        if ($item.Attributes -match 'ReparsePoint') {
            $currentTarget = (Get-Item -LiteralPath $Link -Force).Target

            # If the symlink already points to the correct target, no need to recreate it
            if ($currentTarget -eq $Target) {
                echo ":white_check_mark: Symlink already exists and points to the correct target." | gum format -t emoji
                return
            } else {
                echo ":warning: Symlink exists but points to a different target. Removing it..." | gum format -t emoji
                Remove-Item -Force $Link
            }
        } else {
            # It's not a symlink, delete it
            echo ":warning: Removing existing '$Link' (not a symlink)..." | gum format -t emoji
            Remove-Item -Recurse -Force $Link
        }
    }

    # Create the symlink
    echo ":construction: Creating symlink from '$Link' to '$Target'" | gum format -t emoji
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force -ErrorAction Stop > $null

    # Check if creation was successful
    if ($?) {
        echo ":white_check_mark: Symlink for '$Link' created successfully." | gum format -t emoji
    } else {
        echo ":x: Failed to create symlink for '$Link'." | gum format -t emoji
    }
}
