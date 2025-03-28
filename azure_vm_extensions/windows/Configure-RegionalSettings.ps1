$Language = "de-DE"
$TimeZone = "W. Europe Standard Time"

# Set locale and regional settings
Import-Module -Name "International"
Set-TimeZone -Id $TimeZone
Set-Culture -CultureInfo $Language #OK
Set-WinSystemLocale -SystemLocale $Language #OK
Set-WinUILanguageOverride -Language $Language
Set-WinUserLanguageList -LanguageList $Language -Force #OK

$RegionInfo = New-Object -TypeName "System.Globalization.RegionInfo" -ArgumentList $Language
Set-WinHomeLocation -GeoId $RegionInfo.GeoId  #OK
Set-SystemPreferredUILanguage -Language $Language

# Kopieren Sie die Einstellungen in das Standard-Benutzerprofil
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True