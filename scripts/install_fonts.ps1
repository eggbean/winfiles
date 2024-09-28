# Install and register fonts

$sourceFontFolder = "$env:USERPROFILE\winfiles\fonts"
$systemFontFolder = "$env:SystemRoot\Fonts"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

# Function to check if the font is already installed in the system (both in the registry and file system)
function Test-FontInstalled {
    param (
        [string]$fontName
    )

    # Check if the font file exists in the Fonts directory
    $fontFileExists = Test-Path (Join-Path $systemFontFolder $fontName)

    # Check the registry for font registration
    $fontRegistered = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue |
                      Where-Object { $_.PSObject.Properties.Value -contains $fontName }

    # Return true if both the file and registry entry are present
    return ($fontFileExists -and $fontRegistered -ne $null)
}

# Function to install or update a font
function Install-Font {
    param (
        [string]$fontPath,
        [string]$fontName
    )

    $fontDestination = Join-Path $systemFontFolder $fontName

    # If the font is already installed (registry and file), skip installation
    if (Test-FontInstalled -fontName $fontName) {
        Write-Host "$fontName is already installed. Skipping installation."
        return
    }

    # If the font is not installed, copy it manually
    try {
        Copy-Item -Path $fontPath -Destination $fontDestination -Force
        Write-Host "Installed $fontName by copying the file."
    }
    catch {
        Write-Host "Error copying ${fontName}: $($_.Exception.Message)"
    }

    # Register the font in the registry
    $regFontName = if ($fontName -like "*.ttf") { "$fontName (TrueType)" } else { "$fontName (OpenType)" }
    New-ItemProperty -Path $registryPath -Name $regFontName -Value $fontName -PropertyType String -Force
    Write-Host "$fontName has been registered in the system registry."

    # Flush the font cache
    Write-Host "Flushing the font cache..."
    & rundll32.exe shell32.dll,SHChangeNotify 0x8000000 0
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

    # Install or update the font
    Install-Font -fontPath $fontFile -fontName $fontName
}

Write-Host "Font installation process completed."
