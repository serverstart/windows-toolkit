function Set-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [object]$Value,
        
        [Parameter(Mandatory)]
        [ValidateSet('String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'QWord')]
        [string]$PropertyType
    )
 
    try {
        # Prüfe ob Parent-Pfad existiert, wenn nicht erstelle ihn
        $parentPath = Split-Path -Path $Path -Parent
        if (-not (Test-Path $parentPath)) {
            Write-Log "Creating parent registry path: $parentPath"
            New-Item -Path $parentPath -Force | Out-Null
        }
 
        # Erstelle/Update Registry Key
        if (-not (Test-Path $Path)) {
            Write-Log "Creating registry path: $Path"
            New-Item -Path $Path -Force | Out-Null
        }

        # Hole aktuellen Wert, falls vorhanden
        $existingValue = $null
        try {
            $existingValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        } catch {
            # Wert existiert noch nicht - das ist OK
        }
 
        Write-Log "Setting registry value '$Name' at '$Path'"
        if ($null -ne $existingValue) {
            Write-Log "Current value: $($existingValue.$Name) - New value: $Value"
        } else {
            Write-Log "Current value: <not set> - New value: $Value"
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force | Out-Null
        Write-Log "Registry value set successfully" -Success
 
    } catch {
        Write-Log "Failed to set registry value: $_" -Danger
        throw
    }
 }