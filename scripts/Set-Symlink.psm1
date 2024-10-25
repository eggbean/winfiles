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
                Write-OutputWithIcon -Message "Symlink already exists and points to the correct target." -IconType "info"
                return
            } else {
                Write-OutputWithIcon -Message "Symlink exists but points to a different target. Removing it..." -IconType "warning"
                Remove-Item -Force $Link
            }
        } else {
            # It's not a symlink, delete it
            Write-OutputWithIcon -Message "Removing existing '$Link' (not a symlink)..." -IconType "warning"
            Remove-Item -Recurse -Force $Link
        }
    }

    # Create the symlink
    Write-OutputWithIcon -Message "Creating symlink from '$Link' to '$Target'" -IconType "working"
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force -ErrorAction Stop > $null

    # Check if creation was successful
    if ($?) {
        Write-OutputWithIcon -Message "Symlink for '$Link' created successfully." -IconType "success"
    } else {
        Write-OutputWithIcon -Message "Failed to create symlink for '$Link'." -IconType "error"
    }
}
