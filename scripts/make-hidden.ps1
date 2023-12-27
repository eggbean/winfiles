$param1 = $args[0]

# Create .hidden files in the top-level directory
$hiddenItemsTopLevel = Get-ChildItem -LiteralPath $param1 -Force -Directory -Attributes !ReparsePoint | Where-Object { $_.Name -notmatch '^\.' }

foreach ($item in $hiddenItemsTopLevel) {
    $hiddenFilePath = Join-Path $item.FullName '.hidden'
    $null = New-Item -Force -Path $hiddenFilePath -Value $null
}

# Apply hidden attribute to files starting with a dot in the top-level directory
Get-ChildItem -Path $param1 -File | Where-Object { $_.Name -match '^\.' } | ForEach-Object {
    $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
}

if ($param1 -ne $HOME) {
    # Traverse subdirectories and create .hidden files as needed
    Get-ChildItem -LiteralPath $param1 -Force -Directory -Recurse -Attributes !ReparsePoint | ForEach-Object {
        $dir = $_
        $hiddenItems = Get-ChildItem -Path $dir.FullName -Force | Where-Object { ($_.Attributes -band [System.IO.FileAttributes]::Hidden) -and ($_.Attributes -band [System.IO.FileAttributes]::Directory) -eq 0 }

        if ($hiddenItems.Count -gt 0) {
            $hiddenContent = $hiddenItems.Name -join "`n"
            $hiddenFilePath = Join-Path $dir.FullName '.hidden'
            $hiddenContent | Set-Content -Path $hiddenFilePath -Force -NoNewline
        } else {
            $hiddenFilePath = Join-Path $dir.FullName '.hidden'
            Remove-Item $hiddenFilePath -Force -ErrorAction SilentlyContinue
        }

        # Apply hidden attribute to files in subdirectories
        Get-ChildItem -Path $_.FullName -File | ForEach-Object {
            if ($_.Name -notmatch '^\.') {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
        }
    }
}
