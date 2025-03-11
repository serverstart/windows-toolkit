param (
    [string]$hostnamesToAdd
)

# Prüfen, ob ein Hostname-String übergeben wurde
if (-not $hostnamesToAdd) {
    Write-Host "Fehler: Bitte mindestens einen Hostnamen als Semikolon-getrennten String übergeben!"
    Write-Host "Beispiel: .\Add-BackConnectionHostName.ps1 -hostnamesToAdd 'sfirm.private.remote-arbeitsplatz.net;fileshare.private.remote-arbeitsplatz.net'"
    exit 1
}

# Hostnamen in eine Liste umwandeln
$hostnamesToAdd = $hostnamesToAdd -split ";"

# Pfad zum Registry-Schlüssel
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$regName = "BackConnectionHostNames"

# Prüfen, ob der Schlüssel existiert
if (!(Test-Path $regPath)) {
    Write-Host "Der Registry-Pfad existiert nicht. Erstelle ihn..."
    New-Item -Path $regPath -Force | Out-Null
}

# Bestehende Werte abrufen
$currentValues = @()
if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
    $currentValues = (Get-ItemProperty -Path $regPath -Name $regName).$regName -split "`n"
}

# Neue Hostnamen hinzufügen, falls sie noch nicht existieren
$addedHostnames = @()
foreach ($hostname in $hostnamesToAdd) {
    $hostname = $hostname.Trim()  # Entferne Leerzeichen um den Hostnamen
    if ($hostname -and $hostname -notin $currentValues) {
        $currentValues += $hostname
        $addedHostnames += $hostname
    }
}

# Falls Änderungen vorgenommen wurden, die Registry aktualisieren
if ($addedHostnames.Count -gt 0) {
    Set-ItemProperty -Path $regPath -Name $regName -Value $currentValues -Type MultiString
    Write-Host "Die folgenden Hostnamen wurden zu BackConnectionHostNames hinzugefügt:`n$($addedHostnames -join "`n")"
}
else {
    Write-Host "Alle angegebenen Hostnamen sind bereits in BackConnectionHostNames eingetragen. Keine Änderungen erforderlich."
}

# Optional: Rechnerneustart für die Änderung (auskommentieren, falls nicht gewünscht)
# Restart-Computer -Force
