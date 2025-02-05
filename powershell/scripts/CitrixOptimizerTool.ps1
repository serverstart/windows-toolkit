# Erstelle temp\CitrixOptimizer Verzeichnis falls es nicht existiert
$downloadPath = "$env:TEMP\CitrixOptimizer"
New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null

# Download Citrix Optimizer Tool
$uri = "https://stavdxwopw3ptwuo4o.blob.core.windows.net/binaries/CitrixOptimizerTool.zip"
$zipFile = "$downloadPath\CitrixOptimizerTool.zip"

Write-Host "Downloading Citrix Optimizer Tool..."
Invoke-WebRequest -Uri $uri -OutFile $zipFile

# Entpacke ZIP-Datei
Write-Host "Extracting Citrix Optimizer Tool..."
Expand-Archive -Path $zipFile -DestinationPath $downloadPath -Force

# Navigiere zum Ordner und führe das Skript aus
Write-Host "Running Citrix Optimizer script..."
Set-Location -Path $downloadPath
& .\CtxOptimizerEngine.ps1 -Source ".\Templates\Citrix_Windows_11_2009.xml" -Mode execute

# Cleanup
Write-Host "Cleaning up..."
Remove-Item -Path $zipFile -Force