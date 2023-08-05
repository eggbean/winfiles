$param1=$args[0]
Get-ChildItem -LiteralPath $param1 -Force -Directory -Recurse | ForEach-Object {
    if ($hiddenItems = $_ | Get-ChildItem -Hidden -Force -Name) {
        # Creates BOM-less UTF-8 files with CRLF line endings and a trailing newline
        New-Item -Force (Join-Path $_.FullName '.hidden') -Value (($hiddenItems -join "`n") + "`n")
    } else {
        $hiddenFile = Join-Path $_.FullName '.hidden'
        if (Test-Path $hiddenFile) {
            Remove-Item $hiddenFile
        }
    }
    Get-ChildItem -Path $_.FullName -Recurse -Filter ".*" | ForEach-Object {
        $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
    }
}

