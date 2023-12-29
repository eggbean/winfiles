$param1 = $args[0]

# Regex pattern to match variations of the home directory
$homeRegexPattern = "/mnt/[a-z]/Users/$env:USERNAME"

# Create .hidden files in the top-level directory
$hiddenItemsTopLevel = Get-ChildItem -LiteralPath $param1 -Force -Directory -Attributes !ReparsePoint | Where-Object { $_.Name -notmatch '^\.' }

foreach ($item in $hiddenItemsTopLevel) {
    $hiddenFilePath = Join-Path $item.FullName '.hidden'

    # Check if .hidden file already exists and is hidden
    if (Test-Path -Path $hiddenFilePath) {
        # Remove the hidden attribute to make it accessible
        Set-ItemProperty -Path $hiddenFilePath -Name Attributes -Value ([System.IO.FileAttributes]::Normal)
    } else {
        # Create the file if it doesn't exist
        $null = New-Item -Force -Path $hiddenFilePath -Value $null
    }
}

# Apply hidden attribute to files starting with a dot in the top-level directory
Get-ChildItem -Path $param1 -File | Where-Object { $_.Name -match '^\.' } | ForEach-Object {
    $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
}

if (-not ($param1 -match $homeRegexPattern -or $param1 -eq $HOME)) {
    # Traverse subdirectories of the specified path, excluding symbolic links
    Get-ChildItem -LiteralPath $param1 -Force -Directory -Recurse -Attributes !ReparsePoint | ForEach-Object {
        $dir = $_

        # Apply hidden attribute to files that start with a dot ('.') in subdirectories
        Get-ChildItem -Path $_.FullName -Force | ForEach-Object {
            if ($_.Name -match '^\.') {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
        }

        # Apply hidden attribute to files specifically named 'desktop.ini' or 'folder.jpg' in subdirectories
        Get-ChildItem -Path $_.FullName -File | ForEach-Object {
            if ($_.Name -eq 'desktop.ini' -or $_.Name -eq 'folder.jpg') {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
        }

        # Collect non-directory hidden items in each directory
        $hiddenItems = Get-ChildItem -Path $dir.FullName -Force | Where-Object { ($_.Attributes -band [System.IO.FileAttributes]::Hidden) -and ($_.Attributes -band [System.IO.FileAttributes]::Directory) -eq 0 }

        # If hidden items exist, create a .hidden file listing them; otherwise, remove existing .hidden file
        if ($hiddenItems.Count -gt 0) {
            $hiddenContent = $hiddenItems.Name -join "`n"
            $hiddenFilePath = Join-Path $dir.FullName '.hidden'
            $hiddenContent | Set-Content -Path $hiddenFilePath -Force -NoNewline
            "`n" | Add-Content -Path $hiddenFilePath -NoNewline
            Set-ItemProperty -Path $hiddenFilePath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
        } else {
            $hiddenFilePath = Join-Path $dir.FullName '.hidden'
            Remove-Item $hiddenFilePath -Force -ErrorAction SilentlyContinue
        }
    }
}
