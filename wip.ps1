# Load serverstart PowerShell library
Get-ChildItem -Path "./functions/" -Filter "*.ps1" -Recurse | ForEach-Object { . $_.FullName }


 # Beispielaufruf:
 $registryChecks = @{
    "HKLM:\SOFTWARE\Microsoft\Teams\IsWVDEnvironment" = propertyType
    "HKLM:\Software\Policies\Microsoft\Windows\Appx\AllowAllTrustedApps" = 1
    "HKLM:\Software\Policies\Microsoft\Windows\Appx\AllowDevelopmentWithoutDevLicense" = "1"
 }
 
Test-RegistryValues -ExpectedValues $registryChecks
 