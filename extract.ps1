# Extract last frame from MP4 videos to PNG files
$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verify FFmpeg is installed
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "FFmpeg is not installed" -ForegroundColor Red
    exit 1
}

# Create temp directory
$tempDir = Join-Path $env:TEMP "ffmpeg_extract"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Function to extract last frame using specified method
function Extract-LastFrame {
    param (
        [string]$InputFile,
        [string]$OutputFile,
        [string]$Method = "reverse"
    )
    
    $command = if ($Method -eq "reverse") {
        "ffmpeg -v quiet -i `"$InputFile`" -vf `"reverse`" -frames:v 1 -update 1 `"$OutputFile`" -y"
    } else {
        "ffmpeg -v quiet -sseof -0.001 -i `"$InputFile`" -frames:v 1 -update 1 `"$OutputFile`" -y"
    }
    
    Invoke-Expression $command
    return Test-Path $OutputFile
}

try {
    # Process each MP4 file
    Get-ChildItem -Filter "*.mp4" | ForEach-Object {
        $outputFile = [System.IO.Path]::ChangeExtension($_.FullName, "png")
        
        # Skip existing PNG files
        if (Test-Path $outputFile) {
            Write-Host "Skipping: $($_.Name) - PNG already exists" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Processing: $($_.Name)"
        $tempFile = Join-Path $tempDir "$($_.BaseName).png"
        
        # Try primary method (reverse filter)
        $success = Extract-LastFrame -InputFile $_.FullName -OutputFile $tempFile -Method "reverse"
        
        # If failed, try alternative method
        if (-not $success) {
            Write-Host "Trying alternative method..." -ForegroundColor Yellow
            $success = Extract-LastFrame -InputFile $_.FullName -OutputFile $tempFile -Method "seek"
        }
        
        # Handle results
        if ($success) {
            Move-Item -Path $tempFile -Destination $outputFile -Force
            Write-Host "Created: $($_.BaseName).png" -ForegroundColor Green
        } else {
            Write-Host "Processing error: $($_.Name)" -ForegroundColor Red
        }
    }
} finally {
    # Cleanup
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

Write-Host "`nProcessing completed!" -ForegroundColor Green 