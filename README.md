# Video Last Frame Extraction

A script for extracting the last frame from video files and saving them in PNG format.

## Features

- Automatic processing of all MP4 files in the current directory
- Extraction and saving of the last frame of each video
- Skipping already processed files when re-running
- Two extraction methods to ensure reliability
- Informative processing status messages

## Requirements

- PowerShell
- FFmpeg (must be installed and available in the system path)

## Usage

1. Place MP4 video files in the script directory
2. Run the `extract.ps1` script
3. The script will create PNG files with the last frames

```powershell
.\extract.ps1
```

## Additional Scripts

- `extract.bat` - Batch file for running the PowerShell script
- `create_test.ps1` - Script for creating test videos (if available)
