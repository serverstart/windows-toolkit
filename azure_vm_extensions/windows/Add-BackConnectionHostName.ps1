param (
    [string]$hostnamesToAdd
)

# Sicherstellen, dass das Argument vorhanden ist
if (-not $hostnamesToAdd) {
    Write-Host "ERROR: Please provide at least one hostname as a semicolon-separated string."
    Write-Host "Example: powershell.exe -ExecutionPolicy Bypass -File Add-BackConnectionHostName.ps1 -hostnamesToAdd 'sfirm.private.remote-arbeitsplatz.net;fileshare.private.remote-arbeitsplatz.net'"
    exit 1
}

# Split the string into an array and remove extra spaces
$hostnamesArray = $hostnamesToAdd -split ";" | ForEach-Object { $_.Trim() }

# Define registry path and value name
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$regName = "BackConnectionHostNames"

# Check if the registry path exists
if (!(Test-Path $regPath)) {
    Write-Host "Creating missing registry path..."
    New-Item -Path $regPath -Force | Out-Null
}

# Get existing values
$currentValues = @()
if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
    $currentValues = (Get-ItemProperty -Path $regPath -Name $regName).$regName -split "`n"
}

# Add new hostnames if not already present
$addedHostnames = @()
foreach ($hostname in $hostnamesArray) {
    if ($hostname -and $hostname -notin $currentValues) {
        $currentValues += $hostname
        $addedHostnames += $hostname
    }
}

# Update registry if new hostnames were added
if ($addedHostnames.Count -gt 0) {
    Set-ItemProperty -Path $regPath -Name $regName -Value $currentValues -Type MultiString
    Write-Host "The following hostnames have been added:"
    Write-Host ($addedHostnames -join "`n")
}
else {
    Write-Host "No changes needed. All hostnames are already present."
}