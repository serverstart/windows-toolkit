# Load serverstart PowerShell library
Invoke-Expression (Invoke-WebRequest "https://raw.githubusercontent.com/serverstart/powershell/main/bootstrap.ps1" -UseBasicParsing).Content

Begin-Task "WVD-Key for Teams"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name "IsWVDEnvironment" -Value 1 -PropertyType DWORD
Complete-Task

Begin-Task "Enable App Side-Loading"
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Appx" -Name "AllowAllTrustedApps" -Value 1 -PropertyType DWORD
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Appx" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -PropertyType DWORD
Complete-Task