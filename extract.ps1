# Extracting the last frame from MP4 video files
# This script processes all MP4 files in the current directory and saves the last frame as PNG

# Output settings
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# FFmpeg check
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "FFmpeg is not installed" -ForegroundColor Red
    exit 1
}

# Temporary directory
$tempDir = Join-Path $env:TEMP "ffmpeg_extract"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Processing all MP4 files in the current directory
    Get-ChildItem -Filter "*.mp4" | ForEach-Object {
        $outputFile = [System.IO.Path]::ChangeExtension($_.FullName, "png")
        
        # Skip if PNG already exists
        if (Test-Path $outputFile) {
            Write-Host "Skipping: $($_.Name) - PNG already exists" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Processing: $($_.Name)"
        
        # Create temporary file and extract the last frame
        $tempFile = Join-Path $tempDir "$($_.BaseName).png"
        
        # Method 1: use reverse filter to get the last frame
        ffmpeg -v quiet -i "$($_.FullName)" -vf "reverse" -frames:v 1 -update 1 "$tempFile" -y
        
        # Move result if successful
        if (Test-Path $tempFile) {
            Move-Item -Path $tempFile -Destination $outputFile -Force
            Write-Host "Created: $($_.BaseName).png" -ForegroundColor Green
        } else {
            # Fallback method if the first one failed
            Write-Host "Attempting extraction using alternative method..." -ForegroundColor Yellow
            
            # Method 2: use -sseof with minimal offset
            ffmpeg -v quiet -sseof -0.001 -i "$($_.FullName)" -frames:v 1 -update 1 "$tempFile" -y
            
            if (Test-Path $tempFile) {
                Move-Item -Path $tempFile -Destination $outputFile -Force
                Write-Host "Created: $($_.BaseName).png" -ForegroundColor Green
            } else {
                Write-Host "Processing error: $($_.Name)" -ForegroundColor Red
            }
        }
    }
} finally {
    # Cleanup
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

Write-Host "`nProcessing completed!" -ForegroundColor Green 