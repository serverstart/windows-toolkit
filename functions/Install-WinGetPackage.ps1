function Install-WinGetPackage {
    param(
        [Parameter(Mandatory = $True)] [String] $AppID,
        [switch]$Uninstall,
        [switch]$AllowUpgrade
    )

    Begin-Task "Install WinGet Package $AppID"

    # Über Registry WinGet-AutoUpdate ermitteln
    $WAUInstallLocation = "$env:programfiles\Winget-AutoUpdate"
    $WAUInstallScript = "$WAUInstallLocation\Winget-Install.ps1"

    # Fallback: WinGet-Install Skript
    $InstallScriptFallback = Join-Path -Path $(Get-ServerStartPowerShellScriptsPath) -ChildPath "winget-install.ps1"

    if (Test-Path $WAUInstallScript) {
        $WAUInstalled = $TRUE;
        Write-Log "Winget-AutoUpdate unter $WAUInstallScript gefunden!" -Success
    } elseif (Test-Path $InstallScriptFallback) {
        $WAUInstalled = $FALSE;
        Write-Log "Winget-AutoUpdate nicht gefunden. Verwende Winget-Install unter $InstallScriptFallback…"
    }

    # LogPath initialisation
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"

    if ($WAUInstalled) {
        $LogPath = "$WAUInstallLocation\Logs\$timestamp"
    }
    else {
        $LogPath = "$env:ProgramData\Winget-AutoUpdate\Logs\$timestamp"
    }
    Write-Log "Verwende Log-Verzeichnis: $LogPath"


    # Erstelle Parameter-String
    $params = "-AppIDs `"$AppID`" -LogPath `"$LogPath`""
    if ($Uninstall) { $params += " -Uninstall" }
    if ($AllowUpgrade) { $params += " -AllowUpgrade" }

    # Starte Winget-AutoUpdate oder lade Winget-Install
    if ($WAUInstalled) {
        Write-Log "Starte Winget-AutoUpdate folgenden Parametern: $params..."

        Invoke-Expression "& `"$WAUInstallLocation\Winget-Install.ps1`" $params"
    }
    else {
        Write-Log "Starte Winget-Install folgenden Parametern: $params..."

        Invoke-Expression "& `"$InstallScriptFallback`" $params"
    }

    
    if ($LASTEXITCODE) {
        Write-Log "Fehler bei der Ausführung von Winget-AutoUpdate!"
        exit 1
    }

    Complete-Task
}