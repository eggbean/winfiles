# Install and register fonts

$sourceFontFolder = "$env:USERPROFILE\winfiles\fonts"
$systemFontFolder = "$env:SystemRoot\Fonts"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

# Function to install font
function Install-Font {
    param (
        [string]$fontPath,
        [string]$fontName
    )

    $fontDestination = Join-Path $systemFontFolder $fontName

    # Determine if the font is TrueType or OpenType for registry key
    $regFontName = if ($fontName -like "*.ttf") { "$fontName (TrueType)" } else { "$fontName (OpenType)" }

    # Check if the font is already registered in the system registry
    $fontRegistered = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match [regex]::Escape($fontName) -and $_.PSChildName -match "(TrueType|OpenType)" }

    # Only proceed with installation if the font is not registered
    if (-not $fontRegistered) {
        # If the font is not registered, copy it to the system fonts folder
        if (-not (Test-Path $fontDestination)) {
            Copy-Item $fontPath -Destination $fontDestination -Force
            Write-Host "Copied $fontName to $systemFontFolder"
        } else {
            Write-Host "$fontName already exists in the system fonts folder."
        }

        # Register the font in the registry
        New-ItemProperty -Path $registryPath -Name $regFontName -Value $fontName -PropertyType String -Force
        Write-Host "$fontName has been registered in the system registry."

    } else {
        Write-Host "$fontName is already registered in the system."
    }
}

# Check if the source font folder exists
if (-not (Test-Path $sourceFontFolder)) {
    Write-Host "Source font folder does not exist: $sourceFontFolder"
    exit
}

# Process all font files recursively in the folder and its subdirectories
Get-ChildItem -Path $sourceFontFolder -Recurse -Include *.ttf, *.otf -File | ForEach-Object {
    $fontFile = $_.FullName
    $fontName = $_.Name

    # Install the font
    Install-Font -fontPath $fontFile -fontName $fontName
}

Write-Host "Font installation process completed."
