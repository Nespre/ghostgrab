# GhostGrab.ps1
# This script ensures the downloader runs using PowerShell 7+

# Obtain directory of .exe or .ps1
$basePath = [System.IO.Path]::GetDirectoryName([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
$scriptToRun = Join-Path $basePath "src\main.ps1"

# Check for PowerShell 7
Write-Host "[INFO] Checking for PowerShell 7..."

$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $pwsh) {
    Write-Host "[ERROR] PowerShell 7 (pwsh.exe) not found in system PATH." -ForegroundColor DarkRed
    Write-Host "Download it from: https://learn.microsoft.com/en-us/powershell/"
    pause
    exit 1
}

# Launch main.ps1 using PowerShell 7 and close this launcher
Start-Process -FilePath $pwsh `
              -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File", "`"$scriptToRun`"" `
              -WindowStyle Normal

exit