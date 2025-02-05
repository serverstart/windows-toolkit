# Erstelle temp\VDOT Verzeichnis falls es nicht existiert
$downloadPath = "$env:TEMP\VDOT"
New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null

# Download VDOT von GitHub
$repo = "The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool"
$uri = "https://github.com/$repo/archive/refs/heads/main.zip"
$zipFile = "$downloadPath\VDOT.zip"

Write-Host "Downloading VDOT from GitHub..."
Invoke-WebRequest -Uri $uri -OutFile $zipFile

# Entpacke ZIP-Datei
Write-Host "Extracting VDOT..."
Expand-Archive -Path $zipFile -DestinationPath $downloadPath -Force

# Finde den entpackten Ordner
$vdotFolder = Get-ChildItem -Path $downloadPath -Directory | Where-Object { $_.Name -like "*Virtual-Desktop-Optimization-Tool*" } | Select-Object -First 1

# Navigiere zum Ordner und führe das Skript aus
if ($vdotFolder) {
    Write-Host "Running VDOT optimization script..."
    Set-Location -Path $vdotFolder.FullName
    & .\Windows_VDOT.ps1 -Optimizations All -AdvancedOptimizations All -AcceptEULA -Verbose
} else {
    Write-Error "Could not find VDOT folder after extraction!"
}

# Cleanup
Write-Host "Cleaning up..."
Remove-Item -Path $zipFile -Force