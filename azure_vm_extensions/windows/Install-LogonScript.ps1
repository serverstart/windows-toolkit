param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptContent
)

# Name der geplanten Aufgabe
$taskName = "serverstart Logon-Script"

# Zielpfad für das Skript
$scriptFolder = "C:\ProgramData\serverstart\local"
$vbsPath = Join-Path $scriptFolder "logon.vbs"
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


# VBS-Skript-Inhalt erstellen
$vbsContent = @"
Dim shell, command
command = "powershell.exe -ExecutionPolicy Bypass -File " & Chr(34) & "$scriptPath" & Chr(34)
Set shell = CreateObject("WScript.Shell")
shell.Run command, 0, false
Set shell = Nothing
"@

# VBS-Datei erstellen/überschreiben
try {
    # Wenn die VBS-Datei existiert, explizit löschen
    if (Test-Path $vbsPath) {
        Remove-Item -Path $vbsPath -Force
        Write-Output "Alte VBS-Datei wurde gelöscht."
    }
    
    # Kurz warten um sicherzustellen, dass das Dateisystem die Löschung abgeschlossen hat
    Start-Sleep -Milliseconds 100
    
    # Neue VBS-Datei schreiben
    Set-Content -Path $vbsPath -Value $vbsContent -Encoding UTF8
    
    # Überprüfen, ob der Schreibvorgang erfolgreich war
    if (Test-Path $vbsPath) {
        $newVbsContent = Get-Content -Path $vbsPath -Raw
        if ($newVbsContent) {
            Write-Output "VBS-Skript wurde erfolgreich nach $vbsPath geschrieben und verifiziert."
        } else {
            throw "VBS-Datei wurde erstellt, scheint aber leer zu sein."
        }
    } else {
        throw "VBS-Datei wurde nicht erfolgreich erstellt."
    }
} catch {
    Write-Error "Fehler beim Erstellen der VBS-Datei: $_"
    exit 1
}

# Base64-String dekodieren und in Datei schreiben
try {
    # Zuerst: Wenn die Datei existiert, explizit löschen
    if (Test-Path $scriptPath) {
        Remove-Item -Path $scriptPath -Force
        Write-Output "Alte Datei wurde gelöscht."
    }
    
    # Kurz warten um sicherzustellen, dass das Dateisystem die Löschung abgeschlossen hat
    Start-Sleep -Milliseconds 100
    
    # Neue Datei schreiben
    $decodedContent = [System.Convert]::FromBase64String($ScriptContent)
    [System.IO.File]::WriteAllBytes($scriptPath, $decodedContent)
    
    # Überprüfen, ob der Schreibvorgang erfolgreich war
    if (Test-Path $scriptPath) {
        $newContent = Get-Content -Path $scriptPath -Raw
        if ($newContent) {
            Write-Output "Skript wurde erfolgreich nach $scriptPath geschrieben und verifiziert."
        } else {
            throw "Datei wurde erstellt, scheint aber leer zu sein."
        }
    } else {
        throw "Datei wurde nicht erfolgreich erstellt."
    }
} catch {
    Write-Error "Fehler beim Dekodieren oder Schreiben des Skripts: $_"
    exit 1
}

# Aktion erstellen
$action = New-ScheduledTaskAction `
    -Execute "cscript.exe" `
    -Argument "`"$vbsPath`""

# Trigger erstellen (Bei Benutzeranmeldung)
$trigger = New-ScheduledTaskTrigger -AtLogon

# Erstellen der Principal-Einstellungen (Ausführung im Benutzerkontext)
# Verwendung der SID für die Benutzergruppe statt des lokalisierten Namens
$Principal = New-ScheduledTaskPrincipal `
    -GroupId "S-1-5-32-545" `
    -RunLevel Limited

# Task-Einstellungen
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

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