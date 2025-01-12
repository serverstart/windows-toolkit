# Load serverstart PowerShell library
Invoke-Expression (Invoke-WebRequest "https://raw.githubusercontent.com/serverstart/powershell/main/bootstrap.ps1" -UseBasicParsing).Content


Begin-Task "Install required packages"
Install-WinGetPackage -AppID "Microsoft.VCRedist.2015+.x64" -AllowUpgrade
Install-WinGetPackage -AppID "Microsoft.VCRedist.2015+.x86" -AllowUpgrade
Install-WinGetPackage -AppID "Microsoft.Edge" -AllowUpgrade
Complete-Task


Begin-Task "Install WebRTC Redirect Service"

# Download
$setup = Invoke-TemporaryFileDownload -Url "https://aka.ms/msrdcwebrtcsvc/msi"

try {
    # Installation
    Start-Process msiexec.exe -ArgumentList "/i `"$webRtcMsiPath`" /quiet /norestart" -Wait
}
catch {
    Write-Log  "Installation fehlgeschlagen! Details: $($_)" -Danger
    exit 1
}

# Aufräumen
Remove-TemporaryFile $setup


Complete-Task


# Installiere Microsoft Teams Bootstrapper
Begin-Task "Teams Installation"

# Download
$teamsBootstrapperPath = Invoke-TemporaryFileDownload -Url "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"

try {
    # Installation
    Write-Log "Starte Teams Installation..."
    $result = & $teamsBootstrapperPath -p | ConvertFrom-Json
    Write-Log "Bootstrapper-Result: $result"

    # JSON prüfen
    if ($result.success -eq $true) {
        Write-Log "Installation von Microsoft Teams erfolgreich" -Success
    } else {
        Write-Log "Installation von Microsoft Teams (Bootstrapper) fehlgeschlagen!" -Danger
        exit 1
    }
} 
catch {
    Write-Log "Installation von Microsoft Teams (Bootstrapper) fehlgeschlagen! $($__psEditorServices_userInput)" -Danger
    exit 1
}

# Aufräumen
Remove-TemporaryFile $teamsBootstrapperPath

Complete-Task