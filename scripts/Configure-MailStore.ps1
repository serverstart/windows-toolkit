[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ServerName
)

function Ensure-RegistryKey {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# Server-URL (Add-in 2 — alter Pfad mit Leerzeichen, separat vom Add-in 3)
$serverKey = 'HKCU:\Software\Policies\deepinvent\MailStore Outlook Add-in 2'
Ensure-RegistryKey -Path $serverKey
Set-ItemProperty -Path $serverKey -Name 'Server Name' -Value $ServerName -Type String

# Office Policy: Add-in erlauben 
$policyKey = 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Resiliency\AddinList'
Ensure-RegistryKey -Path $policyKey
Set-ItemProperty -Path $policyKey -Name 'MailStoreOutlookAddin3.AddinModule' -Value '1' -Type String

# Outlook Addin LoadBehavior — 3 = beim Start laden
$addinKey = 'HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MailStoreOutlookAddin3.AddinModule'
Ensure-RegistryKey -Path $addinKey
Set-ItemProperty -Path $addinKey -Name 'LoadBehavior' -Value 3 -Type DWord

# DoNotDisableAddinList pinnen
$doNotDisableKey = 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList'
Ensure-RegistryKey -Path $doNotDisableKey
Set-ItemProperty -Path $doNotDisableKey -Name 'MailStoreOutlookAddin3.AddinModule' -Value 1 -Type DWord