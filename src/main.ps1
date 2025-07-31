# main.ps1
# Author: Lucas Marques
# Description: Video downloader via yt-dlp and ffmpeg, with standardized output


# POWERSHELL LAUNCH ================================================

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[FATAL] PowerShell 7 is required. Please launch using downloader.ps1." -ForegroundColor DarkRed
    Request-Termination -mode "exit" -code 1
}
else{
    Write-Host "[OK] Running with PowerShell version $($PSVersionTable.PSVersion.ToString())" -ForegroundColor Green
    Write-Host ""
}


# FOLDERS & IMPORT ================================================

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDir = Resolve-Path -LiteralPath (Join-Path $scriptDir "..")

$errorsFile = Join-Path $rootDir "src\errors_message.ps1"
$utilsFile = Join-Path $rootDir "src\utils_functions.ps1"
if (-not (Test-Path $errorsFile)) {
    Write-Host "[FATAL] Missing file: errors_message.ps1" -ForegroundColor DarkRed
    Request-Termination -mode "exit" -code 1
}
if (-not (Test-Path $utilsFile)) {
    Write-Host "[FATAL] Missing file: utils_functions.ps1" -ForegroundColor DarkRed
    Request-Termination -mode "exit" -code 1
}
. $errorsFile
. $utilsFile

$toolsFolder = Join-Path $rootDir "tools"
$logsFolder = Join-Path $rootDir "logs"
Ensure-FolderExists $logsFolder
$cookiesFolder = Join-Path $rootDir "cookies"
$defaultDownloadsDir = Join-Path $rootDir "downloads"


# FILES VERIFICATIONS ================================================

Write-Host "[INFO] Current directory: $scriptDir"
Write-Host "[INFO] Checking folder: $toolsFolder"
Write-Host ""

$terminator = Check-RequiredFile $toolsFolder "Folder tools" {Show-MissingToolsFolder}
if ($terminator) {
    Request-Termination -mode "exit" -code 1
}

$ytDlpPath = Join-Path $toolsFolder "yt-dlp.exe"
$terminator = Check-RequiredFile $ytDlpPath "yt-dlp.exe" { Show-MissingYtdlpFile }
if ($terminator) {
    Request-Termination -mode "exit" -code 1
}

$ffmpegPath = Join-Path $toolsFolder "ffmpeg.exe"
$terminator = Check-RequiredFile $ytDlpPath "yt-dlp.exe" { Show-MissingFfmpegFile }
if ($terminator) {
    Request-Termination -mode "continue"
}

Write-Host ""


# URL & CONFIGURE LOGS ================================================

$logsEnabled = Get-LogsPreference -logsFolder $logsFolder

if ($null -eq $logsEnabled) {
    $logsEnabled = Configure-LogsPreference -logsFolder $logsFolder
    Start-Sleep -Seconds 1
}

Write-Host "Enter video/page URL."
Write-Host "Or type 'L' to reconfigure log preferences."
$url = Read-Host "Insert URL"

if ($url -match "^[Ll]$") {
    $logsEnabled = Configure-LogsPreference -logsFolder $logsFolder
    Start-Sleep -Seconds 1
    $url = Read-Host "Insert URL"
}

if ([string]::IsNullOrWhiteSpace($url)) {
    Write-Host "[ERROR] No URL provided." -ForegroundColor DarkRed
    Request-Termination -mode "exit" -code 1
}

Validate-UrlFormat -url $url

Write-Host ""


# COOKIES VERIFICATIONS ================================================

Write-Host "[INFO] Checking if this video requires authentication or cookies..." -ForegroundColor Cyan

$withCookies = $false
$resultWithoutCookies = Get-VideoMetadata -url $url

try {
    $uri = [System.Uri]$url
    $domain = $uri.Host -replace "^www\.", ""
} catch {
    $domain = "unknown"
}

$cookieFile = Join-Path $cookiesFolder "cookies_$domain.txt"

$validWithoutCookies = Is-VideoValid -json $resultWithoutCookies.Json

if (-not $validWithoutCookies -and (Test-Path $cookieFile)) {
    Write-Host "[INFO] Video metadata incomplete or failed without cookies. Retrying with cookies..."

    $resultWithCookies = Get-VideoMetadata -url $url -cookiesPath $cookieFile
    $validWithCookies = Is-VideoValid -json $resultWithCookies.Json

    if (-not $validWithCookies) {
        Show-InvalidCookies
        Request-Termination -mode "exit" -code 1
    } else {
        Write-Host "[OK] Cookies are valid. Authenticated download will be used." -ForegroundColor Green
        $withCookies = $true
    }
}
elseif ($validWithoutCookies) {
    Write-Host "[OK] No authentication required." -ForegroundColor Green
}
elseif (-not (Test-Path $cookieFile)) {
    Show-MissingCookies
    Request-Termination -mode "exit" -code 1
}

Write-Host ""


# FILE NAME ================================================

Write-Host "[INFO] Getting video title..." -ForegroundColor Cyan
$videoTitle = Get-VideoTitle -url $url -withCookies $withCookies -cookieFile $cookieFile -ytDlpPath $ytDlpPath
Write-Host ""

Write-Host "Default file name: $videoTitle"
$fileNameInput = Read-Host "Type desired file name (or press ENTER to use Default)"

$finalFileName = if ([string]::IsNullOrWhiteSpace($fileNameInput)) {
    $videoTitle
} else {
    $fileNameInput
}

$finalFileName = Sanitize-FileName -name $finalFileName

if ([string]::IsNullOrWhiteSpace($finalFileName)) {
    Write-Host "[WARNING] File name became empty after sanitization. Using default 'video'." -ForegroundColor DarkYellow
    $finalFileName = "video"
}


# CHOOSE DIRECTORY ================================================

if (-not (Test-Path $defaultDownloadsDir)) {
    New-Item -ItemType Directory -Path $defaultDownloadsDir | Out-Null
}

Write-Host ""
Write-Host "Default output directory: $defaultDownloadsDir"
Write-Host "[INFO] Customize directory example: C:\Users\username\Videos"
$customDir = Read-Host "Type desired output directory (or press ENTER to use Default)"

$outputDir = if (-not [string]::IsNullOrWhiteSpace($customDir)) {
    $customDir
} else {
    $defaultDownloadsDir
}

Ensure-DirectoryExists -directoryPath $outputDir
$outputTemplate = Join-Path $outputDir "$finalFileName.%(ext)s"


# ATTEMPT DOWNLOAD ===================================================

Write-Host ""
$downloadSuccess = $false

while (-not $downloadSuccess) {
    Write-Host "[INFO] Attempting download $($withCookies ? 'WITH' : 'WITHOUT') cookies..." -ForegroundColor Cyan

    $downloadArgs = Build-DownloadArguments -ffmpegPath $ffmpegPath -outputTemplate $outputTemplate -withCookies $withCookies -cookieFile $cookieFile

    & $ytDlpPath @downloadArgs "$url"
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        $downloadSuccess = $true
        Check-FileAndConclude -downloadDir $outputDir -fileNameBase $finalFileName
    }
    else {
        if ($withCookies) {
            Write-Host "[ERROR] Download failed even with cookies." -ForegroundColor Red
            Show-InvalidCookies
            Request-Termination -mode "exit" -code 1
        }
        else {
            Write-Host "[ERROR] Download failed without cookies." -ForegroundColor DarkRed

            if (Test-Path $cookieFile) {
                $response = Read-Host "Would you like to retry using cookies? (Y/N)"
                if ($response -match "^[Yy]$") {
                    $withCookies = $true
                    Write-Host ""
                    continue
                } else {
                    Write-Host "[INFO] User chose not to retry with cookies."
                    Request-Termination -mode "exit" -code 1
                }
            } else {
                Show-MissingCookies
                Request-Termination -mode "exit" -code 1
            }
        }
    }
}