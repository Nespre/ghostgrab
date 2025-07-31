function Request-Termination {
    param (
        [ValidateSet("exit", "continue")]
        [string]$mode,

        [ValidateSet(0, 1)]
        [int]$code = 0
    )

    if ($mode -eq "exit") {
        Write-Host ""
        Write-Host "Program will now exit. Press Enter to continue..."
        Read-Host | Out-Null
        exit $code
    } elseif ($mode -eq "continue") {
        Write-Host ""
        Write-Host "Continuing... Press Enter to proceed."
        Read-Host | Out-Null
    }
}


function Check-RequiredFile {
    param (
        [string]$path,             
        [string]$displayName,      
        [scriptblock]$onMissing    
    )

    if (Test-Path $path) {
        Write-Host "[OK] $displayName found." -ForegroundColor Green
        return $false
    } else {
        & $onMissing
        return $true
    }
}


function Ensure-FolderExists {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}


function Get-LogsPreference {
    param([string]$logsFolder)

    $trueFlag = Join-Path $logsFolder "logs_true.txt"
    $falseFlag = Join-Path $logsFolder "logs_false.txt"

    if (Test-Path $trueFlag) { return $true }
    elseif (Test-Path $falseFlag) { return $false }
    else { return $null }  # Not Configured
}


function Configure-LogsPreference {
    param([string]$logsFolder)

    $trueFlag = Join-Path $logsFolder "logs_true.txt"
    $falseFlag = Join-Path $logsFolder "logs_false.txt"

    Remove-Item $trueFlag, $falseFlag -Force -ErrorAction SilentlyContinue

    Write-Host "Do you want to keep download and error logs? (Y/N)"

    while ($true) {
        $choice = Read-Host "Your choice"
        if ($choice -match "^[Yy]$") {
            New-Item -ItemType File -Path $trueFlag | Out-Null
            Write-Host "[INFO] Logging enabled.`n" -ForegroundColor Cyan
            return $true
        } elseif ($choice -match "^[Nn]$") {
            New-Item -ItemType File -Path $falseFlag | Out-Null
            Write-Host "[INFO] Logging disabled.`n" -ForegroundColor Cyan
            return $false
        } else {
            Write-Host "[WARNING] Invalid input. Please type Y or N." -ForegroundColor DarkYellow
        }
    }
}


function Validate-UrlFormat {
    param (
        [string]$url
    )

    Write-Host ""

    try {
        $uri = [System.Uri]$url
        if (-not $uri.Scheme -or -not $uri.Host) {
            throw "URL is missing scheme or host."
        }
    } catch {
        Write-Host "[ERROR] The provided URL is not valid: $url" -ForegroundColor Red
        Write-Host "Please check the URL and try again."
        Request-Termination -mode "exit" -code 1
    }
}


function Get-VideoMetadata {
    param (
        [string]$url,
        [string]$cookiesPath = $null
    )

    $args = "--no-warnings --dump-json `"$url`""
    if ($cookiesPath) {
        $args = "--no-warnings --cookies `"$cookiesPath`" --dump-json `"$url`""
    }

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $ytDlpPath
    $processInfo.Arguments = $args
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    $output = $process.StandardOutput.ReadToEnd()
    $error = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    # Tenta converter o output para JSON (opcional, caso queiras usar no futuro)
    $json = $null
    try {
        $json = $output | ConvertFrom-Json
    } catch {
        # Não faz nada, JSON inválido
    }

    return @{
        Output = $output
        Error = $error
        Json = $json
    }
}


function Is-VideoValid {
    param ([object]$json)

    return (
        $json -and
        $json.formats -and
        $json.formats.Count -gt 0
    )
}


function Get-VideoTitle {
    param (
        [string]$url,
        [bool]$withCookies,
        [string]$cookieFile,
        [string]$ytDlpPath
    )

    try {
        $title = if ($withCookies -and (Test-Path $cookieFile)) {
            & $ytDlpPath --cookies "$cookieFile" --get-title "$url"
        } else {
            & $ytDlpPath --get-title "$url"
        }

        if ([string]::IsNullOrWhiteSpace($title)) {
            return "video"
        }

        return $title
    } catch {
        return "video"
    }
}


function Sanitize-FileName {
    param ([string]$name)

    $pattern = '[<>:"/\\|?*]'
    $invalidChars = ($name -split '').Where({$_ -match $pattern}) | Select-Object -Unique

    if ($invalidChars.Count -gt 0) {
        $invalidList = ($invalidChars -join ' ')
        Write-Host "[WARNING] The following characters are invalid and will be removed: $invalidList" -ForegroundColor DarkYellow
    }

    return ($name -replace $pattern, '').Trim()
}


function Ensure-DirectoryExists {
    param (
        [string]$directoryPath
    )

    if (-not (Test-Path $directoryPath)) {
        Write-Host ""
        Write-Host "[WARNING] Output directory does not exist: $directoryPath" -ForegroundColor DarkYellow
        $choice = Read-Host "Press ENTER para criar ou X para sair"

        switch -regex ($choice) {
            "^[Xx]$" {
                Request-Termination -mode "exit" -code 0
            }
            "^\s*$" {
                try {
                    New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
                    Write-Host "[OK] Directory created: $directoryPath" -ForegroundColor Green
                } catch {
                    Write-Host "[ERROR] Failed to create directory: $directoryPath" -ForegroundColor DarkRed
                    Request-Termination -mode "exit" -code 1
                }
            }
            default {
                Write-Host "[ERROR] Invalid choice. Exiting program..." -ForegroundColor DarkRed
                Request-Termination -mode "exit" -code 1
            }
        }
    }
}


function Build-DownloadArguments {
    param (
        [string]$ffmpegPath,
        [string]$outputTemplate,
        [bool]$withCookies,
        [string]$cookieFile
    )

    $args = @(
        "--ffmpeg-location", $ffmpegPath,
        "-f", "bv+ba/best",
        "-o", $outputTemplate,
        "--merge-output-format", "mp4"
    )

    if ($withCookies) {
        $args += @("--cookies", $cookieFile)
    }

    return $args
}


function Check-FileAndConclude {
    param (
        [string]$downloadDir,
        [string]$fileNameBase
    )

    $files = Get-ChildItem -Path $downloadDir -Filter "$fileNameBase.*" -ErrorAction SilentlyContinue

    if ($files) {
        Write-Host ""
        Write-Host "[OK] Download completed successfully!" -ForegroundColor Green
        foreach ($file in $files) {
            Write-Host "File saved as: $($file.FullName)"
        }
        Request-Termination -mode "exit" -code 0
    } else {
        Write-Host "[WARNING] No output files found, even though yt-dlp reported success." -ForegroundColor Yellow
        Request-Termination -mode "exit" -code 1
    }
}


function Rotate-LogFile {
    param(
        [string]$logPath,
        [string]$baseName  # "downloads" ou "error"
    )

    $maxSize = 1MB
    if (Test-Path $logPath -and (Get-Item $logPath).Length -gt $maxSize) {
        $i = 0
        do {
            $archivedPath = Join-Path -Path (Split-Path $logPath) -ChildPath "${baseName}_old$i.log"
            $i++
        } while (Test-Path $archivedPath)

        Rename-Item -Path $logPath -NewName (Split-Path $archivedPath -Leaf)
    }
}


function Log-Error {
    param([string]$message)
    
    if ($logsEnabled) {
        $logPath = "$logsFolder\error.log"
        Rotate-LogFile -logPath $logPath -baseName "error"

        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "[$timestamp] ERROR: $message"
    }
}


function Log-Download {
    param(
        [string]$title,
        [string]$outputPath
    )

    if ($logsEnabled) {
        $logPath = "$logsFolder\downloads.log"
        Rotate-LogFile -logPath $logPath -baseName "downloads"

        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logPath -Value "[$timestamp] Downloaded: `"$title`" → $outputPath"
    }
}