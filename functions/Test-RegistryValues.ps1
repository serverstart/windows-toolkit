function Test-RegistryValues {
    param(
        [Parameter(Mandatory)]
        [hashtable]$ExpectedValues
    )

    Begin-Task "Test Registry Values"
 
    try {
        $totalCount = $ExpectedValues.Count
        $missingKeys = 0
        $wrongValues = 0
        $correctValues = 0
 
        foreach ($regPath in $ExpectedValues.Keys) {
            $expectedValue = $ExpectedValues[$regPath]
            
            # Pfad und Name trennen
            $path = Split-Path -Path $regPath
            $name = Split-Path -Path $regPath -Leaf
            
            Write-Log "Checking registry value at '$regPath'"
            
            # Prüfe ob Key existiert
            if (-not (Test-Path $path)) {
                Write-Log "Registry key '$path' does not exist" -Warning
                $missingKeys++
                continue
            }
 
            # Wert abrufen
            try {
                $currentValue = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction Stop
                
                if ($currentValue -ne $expectedValue) {
                    Write-Log "Value mismatch! (Value found: $currentValue - Expected: $expectedValue)" -Warning -SuffixNewline
                    $wrongValues++
                } else {
                    Write-Log "Value matches configuration (Value found: $currentValue)" -Success -SuffixNewline
                    $correctValues++
                }
            }
            catch {
                Write-Log "Registry value '$name' not found in '$path'" -Warning -SuffixNewline
                $missingKeys++
            }
        }
        
        # Zusammenfassung
        Write-Log "Registry check summary:" -Info
        Write-Log "> Total checks: $totalCount"
        Write-Log "> Correct values: $correctValues"
        Write-Log "> Wrong values: $wrongValues"
        Write-Log "> Missing keys/values: $missingKeys" -SuffixNewline
 
        # Status-String zurückgeben
        if ($missingKeys -gt 0) {
            Write-Log "Result: CHECK_FAILED" -Warning
        }
        elseif ($wrongValues -gt 0) {
            Write-Log "Result: CHECK_FAILED" -Warning
        }
        else {
            Write-Log "Result: CHECK_PASSED" -Success
        }
        
    } catch {
        Write-Log "Error checking registry values: $_" -Danger
        Write-Log "Result: CHECK_ERROR" -Danger
    }

    Complete-Task
 }