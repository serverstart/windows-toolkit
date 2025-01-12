function Install-WinGetPackage {
    param(
        [Parameter(Mandatory)]
        [Parameter(Mandatory = $True, ParameterSetName = "AppIDs")] [String[]] $AppIDs,
        [switch]$Uninstall,
        [switch]$AllowUpgrade
    )

    Begin-Task "WinGet Execution"

    # Über Registry WinGet-AutoUpdate ermitteln
    Write-Log "Prüfe auf Installation von Winget-AutoUpdate..."
    $WAUInstallLocation = "$env:programfiles\Winget-AutoUpdate"
    $WAUInstallScript = "$WAUInstallLocation\Winget-Install.ps1"

    Write-Log "Prüfe, ob Datei $WAUInstallScript verfügbar ist..."

    if (Test-Path $WAUInstallScript) {
    $WAUInstalled = $TRUE;
    Write-Log "Winget-AutoUpdate gefunden!" -Success
    } else {
    $WAUInstalled = $FALSE;
    Write-Log "× Winget-AutoUpdate nicht gefunden. Verwende Winget-Install…"
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
    $params = "-AppIDs `"$AppIDs`" -LogPath `"$LogPath`""
    if ($Uninstall) { $params += " -Uninstall" }
    if ($AllowUpgrade) { $params += " -AllowUpgrade" }

    # Starte Winget-AutoUpdate oder lade Winget-Install
    if ($WAUInstalled) {
        Write-Log "Starte Winget-AutoUpdate mit Parametern..."

        Invoke-Expression "& `"$WAUInstallLocation\Winget-Install.ps1`" $params"
        if ($LASTEXITCODE) {
            Write-Log "Fehler bei der Ausführung von Winget-AutoUpdate!"
            exit 1
        }
    }
    else {
        Write-Log "Starte Winget-Install mit Parametern..."

        $xpath = Join-Path -Path $(Get-ServerStartPowerShellScriptsPath) -ChildPath "winget-install.ps1"        
        Invoke-Expression "& `"$xpath`" $params"

    }
}