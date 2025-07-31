function Show-MissingToolsFolder {
    Write-Host "[ERROR] Missing folder: tools" -ForegroundColor DarkRed
    Write-Host "This folder is required for the program to run.`n"
    Write-Host "To fix this, follow these steps:"
    Write-Host "  1. In the same folder as this script, create a new folder named: tools"
    Write-Host "  2. Make sure it's spelled exactly like that (all lowercase, no spaces)"
    Write-Host "  3. Then place the necessary tools inside it (ytdlp.exe and ffmpeg.exe)`n"
}


function Show-MissingYtdlpFile {
    Write-Host "[ERROR] Missing required file: yt-dlp.exe" -ForegroundColor DarkRed
    Write-Host "This program cannot run without yt-dlp.`n"
    Write-Host "To fix this, follow these steps:"
    Write-Host "  1. Go to: https://github.com/yt-dlp/yt-dlp/releases"
    Write-Host "  2. Download the file named: yt-dlp.exe"
    Write-Host "  3. Move the file into the folder: tools`n"
}


function Show-MissingFfmpegFile {
    Write-Host "[WARNING] Missing optional file: ffmpeg.exe" -ForegroundColor DarkYellow
    Write-Host "The download will still work, but the program won't be able to merge video and audio without ffmpeg.`n"
    Write-Host "To enable audio+video merging, follow these steps:"
    Write-Host "  1. Go to: https://www.gyan.dev/ffmpeg/builds/"
    Write-Host "  2. Download the release: ffmpeg-release-essentials.zip"
    Write-Host "  3. Extract the file and locate: ffmpeg.exe (inside the 'bin' folder)"
    Write-Host "  4. Move only ffmpeg.exe into the folder: tools"
    Write-Host "  5. You can delete the rest of the extracted files — only ffmpeg.exe is needed`n"
}


function Show-MissingCookies {
    Write-Host ""
    Write-Host "[ERROR] Missing cookies file: cookies_$domain.txt" -ForegroundColor DarkRed
    Write-Host "This video requires authentication (e.g. age-restricted or private content)."
    Write-Host "yt-dlp needs cookies to access these types of videos.`n"
    Write-Host "To fix this, follow these steps:"
    Write-Host "  1. Open the website in your browser (e.g. YouTube) and log in."
    Write-Host "  2. Use an extension like 'Get cookies.txt' to export your cookies."
    Write-Host "     Chrome/Edge/Firefox: https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp"
    Write-Host "  3. Save the exported file as: cookies_$domain.txt"
    Write-Host "  4. Place this file in the 'cookies' folder.`n"
}


function Show-InvalidCookies {
    Write-Host ""
    Write-Host "[ERROR] Cookies found but appear to be invalid or expired." -ForegroundColor Red
    Write-Host "This could be due to one of the following reasons:`n"
    Write-Host "  - The cookies are expired or invalid (e.g. logged out)."
    Write-Host "  - The video requires additional authentication (e.g. two-factor login)."
    Write-Host "  - The video is region-restricted or removed."
    Write-Host "  - yt-dlp may be outdated or not support the current site structure.`n"
    Write-Host "Suggested actions:"
    Write-Host "  - Try exporting a fresh cookies file and replacing the old one."
    Write-Host "  - Visit the video in your browser to confirm it plays normally."
    Write-Host "  - Check if yt-dlp has updates: https://github.com/yt-dlp/yt-dlp/releases`n"
}