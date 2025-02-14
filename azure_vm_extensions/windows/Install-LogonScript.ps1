param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptContent
)

# Name der geplanten Aufgabe
$taskName = "serverstart Logon-Script"

# Zielpfad für das Skript
$scriptFolder = "C:\ProgramData\serverstart\local"
$scriptPath = Join-Path $scriptFolder "logon.ps1"

# Erstelle Verzeichnis falls es nicht existiert
if (-not (Test-Path $scriptFolder)) {
    try {
        New-Item -Path $scriptFolder -ItemType Directory -Force | Out-Null
        Write-Output "Verzeichnis $scriptFolder wurde erstellt."
    } catch {
        Write-Error "Fehler beim Erstellen des Verzeichnisses: $_"
        exit 1
    }
}

# Base64-String dekodieren und in Datei schreiben
try {
    $decodedContent = [System.Convert]::FromBase64String($ScriptContent)
    [System.IO.File]::WriteAllBytes($scriptPath, $decodedContent)
    Write-Output "Skript wurde erfolgreich nach $scriptPath geschrieben."
} catch {
    Write-Error "Fehler beim Dekodieren oder Schreiben des Skripts: $_"
    exit 1
}

# Aktion erstellen
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Trigger erstellen (Bei Benutzeranmeldung)
$trigger = New-ScheduledTaskTrigger -AtLogon

# Hauptbenutzer-Einstellungen
$principal = New-ScheduledTaskPrincipal `
    -GroupId "INTERACTIVE" `
    -RunLevel Limited

# Task-Einstellungen
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
    -MultipleInstances IgnoreNew

try {
    # Überprüfen, ob die Aufgabe bereits existiert
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($existingTask) {
        # Aufgabe aktualisieren
        Set-ScheduledTask `
            -TaskName $taskName `
            -Action $action `
            -Trigger $trigger `
            -Principal $principal `
            -Settings $settings
        
        Write-Output "Die geplante Aufgabe '$taskName' wurde erfolgreich aktualisiert."
    } else {
        # Neue Aufgabe erstellen
        Register-ScheduledTask `
            -TaskName $taskName `
            -Action $action `
            -Trigger $trigger `
            -Principal $principal `
            -Settings $settings
        
        Write-Output "Die geplante Aufgabe '$taskName' wurde erfolgreich erstellt."
    }
} catch {
    Write-Error "Fehler beim Erstellen/Aktualisieren der geplanten Aufgabe: $_"
    exit 1
}