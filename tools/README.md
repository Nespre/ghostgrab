# 📁 tools

This folder contains third-party binaries required for GhostGrab to function:

- `yt-dlp.exe`: Handles video extraction and downloading.
- `ffmpeg.exe`: Handles media merging and conversion.

These files must exist for the downloader to operate properly.

<br>

## 🔧 Requirements / Setup

GhostGrab depends on two external tools which are not included in the repository, but can be easily added manually:

1. yt-dlp.exe (required)

Used for downloading video and audio from supported platforms.

## 📦 Install Steps:

    Visit: yt-dlp Releases

    Download the file: yt-dlp.exe

    Move it to the tools/ folder inside this project.

2. ffmpeg.exe (optional but recommended)

Used for merging separate audio and video tracks into a single file.

## 📦 Install Steps:

    Visit: FFmpeg Windows Builds

    Download: ffmpeg-release-essentials.zip

    Extract it, and locate the file: ffmpeg.exe inside the bin/ folder

    Copy only ffmpeg.exe to the tools/ folder

    You can delete the rest of the extracted files.

    ⚠️ If ffmpeg.exe is missing, GhostGrab will still download the media, but the final file may lack proper audio+video merging.
