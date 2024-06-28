# Exclude known false positives from Windows Defender scanning

$filesToExclude = @(
    "$env:USERPROFILE\winfiles\bin\cmdow.exe",
    "$env:USERPROFILE\winfiles\bin\GDProps.exe"
)

foreach ($file in $filesToExclude) {
    Add-MpPreference -ExclusionPath $file -Force
}

Write-Host "Excluded the specified files from Windows Defender."
