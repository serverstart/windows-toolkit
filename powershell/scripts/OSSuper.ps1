# Erstelle die benötigten Verzeichnisse
$baseDir = "C:\OSOptimizationTool"
$reportsDir = Join-Path $baseDir "reports"

New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

# URL für den Download des Tools
$toolUrl = "https://serverstart.blob.core.windows.net/download/OmnissaHorizonOSOptimizationTool-x86_64-1.2.2412.12943850210.exe"
$toolPath = Join-Path $baseDir "OSOptimizationTool.exe"

# Download des Tools
try {
    Invoke-WebRequest -Uri $toolUrl -OutFile $toolPath
} catch {
    Write-Error "Fehler beim Herunterladen des Tools: $_"
    exit 1
}

# Prüfe, ob die Datei erfolgreich heruntergeladen wurde
if (-not (Test-Path $toolPath)) {
    Write-Error "Tool wurde nicht erfolgreich heruntergeladen."
    exit 1
}

# Tool mit allen Parametern ausführen und Ausgabe in Datei umleiten
try {
    # Direkter Aufruf des Tools mit Ausgabeumleitung
    $outputPath = Join-Path $baseDir "output.txt"
    & $toolPath  -v -o all-item -r C:\OSOptimizationTool\reports -t "Omnissa Templates\\Windows 10, 11 and Server 2019, 2022" -VisualEffect Balanced -Notification Enable -WindowsUpdate Enable -OfficeUpdate Enable -storeapp remove-all --exclude Calculator WebExtension > $outputPath 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tool wurde mit Fehler beendet. ExitCode: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "Fehler beim Ausführen des Tools: $_"
    exit 1
}

Write-Output "Optimierung erfolgreich abgeschlossen."