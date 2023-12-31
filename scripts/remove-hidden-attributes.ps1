$param1 = $args[0]

# Check if the directory exists
if (Test-Path -Path $param1 -PathType Container) {
    # Remove hidden attribute from all files in the directory and its subdirectories
    Get-ChildItem -Path $param1 -File -Recurse -Force | ForEach-Object {
        if ($_.Attributes -band [System.IO.FileAttributes]::Hidden) {
            $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
        }
    }

    # Remove hidden attribute from all directories in the directory and its subdirectories
    Get-ChildItem -Path $param1 -Directory -Recurse -Force | ForEach-Object {
        if ($_.Attributes -band [System.IO.FileAttributes]::Hidden) {
            $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
        }
    }
} else {
    Write-Host "Directory $param1 does not exist."
}
