# Load serverstart PowerShell library
Invoke-Expression (Invoke-WebRequest "https://raw.githubusercontent.com/serverstart/powershell/main/bootstrap.ps1" -UseBasicParsing).Content

Test-RegistryValues -ExpectedValues @{
    "HKLM:\SOFTWARE\Microsoft\Teams\IsWVDEnvironment" = propertyType
    "HKLM:\Software\Policies\Microsoft\Windows\Appx\AllowAllTrustedApps" = 1
    "HKLM:\Software\Policies\Microsoft\Windows\Appx\AllowDevelopmentWithoutDevLicense" = "1"
}