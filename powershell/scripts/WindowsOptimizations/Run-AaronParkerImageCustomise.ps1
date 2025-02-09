# Erstelle temp\ImageCustomise Verzeichnis falls es nicht existiert
$downloadPath = "$env:TEMP\ImageCustomise"
New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null

# API-Aufruf um die neueste Release-URL zu bekommen
$repo = "aaronparker/image-customise"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"

Write-Host "Getting latest release information..."
$release = Invoke-RestMethod -Uri $apiUrl
$downloadUrl = $release.assets | Where-Object { $_.name -eq 'image-customise.zip' } | Select-Object -ExpandProperty browser_download_url
$zipFile = "$downloadPath\ImageCustomise.zip"

# Download der neuesten Version
Write-Host "Downloading latest Image Customise release..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

# Entpacke ZIP-Datei
Write-Host "Extracting Image Customise..."
Expand-Archive -Path $zipFile -DestinationPath $downloadPath -Force

# Navigiere zum Ordner und führe das Skript aus
Write-Host "Running Install-defaults script..."
Set-Location -Path $downloadPath
& .\Install-defaults.ps1 -Language "de-DE" -TimeZone "Mitteleuropäische Zeit" -Verbose

# Führe Remove-AppxApps aus
Write-Host "Running Remove-AppxApps script..."
Set-Location -Path $downloadPath
& .\Remove-AppxApps.ps1

# Cleanup
Write-Host "Cleaning up..."
Remove-Item -Path $zipFile -Force