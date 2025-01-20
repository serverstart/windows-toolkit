# This bootstrap script manages automatic updates of the serverstart PowerShell Library.
# - Updates are checked once per day to avoid unnecessary GitHub API calls
# - Local Version state is tracked via update.json containing commit hash and last check date
# - Offline capability: Falls back to local version if GitHub is unreachable
# - Minimal disk operations: Only updates files when actual changes are detected via hash comparison
$targetPath = "$env:ProgramData\serverstart"
$updateFile = Join-Path $targetPath "update.json"
$functionsPath = Join-Path $targetPath "powershell\functions"

Write-Host "[Bootstrap] Initializing serverstart Windows-Toolkit" -ForegroundColor Cyan

# Ensure our base structure exists
if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Write-Host "[Bootstrap] Created new installation directory" -ForegroundColor Yellow
}

try {
    $needsUpdate = $true
    
    # Check existing installation state
    if (Test-Path $updateFile) {
        try {
            $status = Get-Content $updateFile -Raw | ConvertFrom-Json
            $lastCheck = [DateTime]::ParseExact($status.last_check, "yyyy-MM-dd", $null)
            
            if ($lastCheck.Date -eq (Get-Date).Date) {
                Write-Host "[Bootstrap] Version check already performed today - locally installed version: $($status.hash)"
                $needsUpdate = $false
            }
        } catch {
            Write-Host "[Bootstrap] Warning: State file corrupted - forcing update check" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[Bootstrap] No installation found - performing initial setup" -ForegroundColor Yellow
    }

    # Version check and update logic
    if ($needsUpdate) {
        Write-Host "[Bootstrap] Checking for available updates..."
        
        try {
            $response = Invoke-RestMethod -Uri "https://api.github.com/repos/serverstart/windows-toolkit/commits/main" -UseBasicParsing -TimeoutSec 10
            $newHash = $response.sha
            Write-Host "[Bootstrap] Latest available version: $newHash"
            
            $currentHash = if (Test-Path $updateFile) {
                $status = Get-Content $updateFile -Raw | ConvertFrom-Json
                Write-Host "[Bootstrap] Installed version: $($status.hash)"
                $status.hash
            } else {
                Write-Host "[Bootstrap] No version currently installed"
                $null
            }

            if ($currentHash -eq $newHash) {
                Write-Host "[Bootstrap] Installation is up to date" -ForegroundColor Cyan
                $needsUpdate = $false
            }

            # Update process: Download, replace files, update state
            if ($needsUpdate) {
                Write-Host "[Bootstrap] Downloading new version..." -ForegroundColor Yellow
                
                try {
                    Invoke-WebRequest "https://github.com/serverstart/windows-toolkit/archive/refs/heads/main.zip" -OutFile "$env:TEMP\ps.zip" -UseBasicParsing
                } catch {
                    throw "Failed to download update package: $($_.Exception.Message)"
                }

                try {
                    Get-ChildItem -Path $targetPath -Exclude "update.json" | Remove-Item -Recurse -Force
                    Expand-Archive "$env:TEMP\ps.zip" -DestinationPath "$env:TEMP" -Force
                    Copy-Item "$env:TEMP\windows-toolkit\*" $targetPath -Recurse -Force
                    Remove-Item "$env:TEMP\ps.zip","$env:TEMP\windows-toolkit" -Recurse -Force
                } catch {
                    throw "Failed to install update: $($_.Exception.Message)"
                }
                
                @{
                    hash = $newHash
                    last_check = Get-Date -Format "yyyy-MM-dd"
                } | ConvertTo-Json | Out-File $updateFile
                Write-Host "[Bootstrap] Update completed successfully" -ForegroundColor Green
            }
        } catch {
            if ($_.Exception.Message -like "*Unable to connect*" -or $_.Exception.Message -like "*The operation has timed out*") {
                Write-Host "[Bootstrap] ERROR: Cannot reach update server - check your internet connection" -ForegroundColor Red
            } else {
                Write-Host "[Bootstrap] ERROR: Update process failed - $($_.Exception.Message)" -ForegroundColor Red
            }
            
            if (Test-Path $updateFile) {
                Write-Host "[Bootstrap] Continuing with existing installation" -ForegroundColor Yellow
            } else {
                Write-Host "[Bootstrap] ERROR: No local version available - updates required for first use" -ForegroundColor Red
                throw "Initial setup failed - library unavailable"
            }
        }
    }

    # Setzt die PowerShell Execution Policy auf RemoteSigned (erlaubt lokale unsigned Scripts + remote signierte Scripts).
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force | Out-Null

    # Load all library functions and scripts
    $functionFiles = if (Test-Path $functionsPath) { Get-ChildItem -Path $functionsPath -Filter "*.ps1" -Recurse } else { @() }
    $totalFunctions = ($functionFiles).Count

    $functionFiles | ForEach-Object { . $_.FullName }
    Write-Host "[Bootstrap] serverstart Windows-Toolkit successfully initialized (loaded $totalFunctions function files)." -ForegroundColor Green
    
} catch {
    Write-Host "[Bootstrap] Critical error loading library: $_" -ForegroundColor Red
    throw
}
