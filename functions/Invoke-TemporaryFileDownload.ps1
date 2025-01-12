function Invoke-TemporaryFileDownload {
    param(
        [Parameter(Mandatory)]
        [string]$Url,
        
        [Parameter()]
        [string]$Filename
    )
   
    try {
        # Wenn kein Filename angegeben, lade die Datei und hole den echten Namen
        if (-not $Filename) {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $null
            $realUrl = $response.BaseResponse.ResponseUri.AbsoluteUri
            $Filename = [System.IO.Path]::GetFileName($realUrl)

            # Wenn immer noch kein Filename, generiere einen
            if ([string]::IsNullOrEmpty($Filename)) {
                $Filename = [System.IO.Path]::GetRandomFileName()
            }
        }

        $fullPath = Join-Path $env:TEMP $Filename
        Write-Log "Downloading file from: $Url"
        
        Invoke-WebRequest -Uri $Url -OutFile $fullPath
        Write-Log "Download successful: $fullPath" -Success
        
        return $fullPath

    } catch {
        Write-Log "Failed to download file: $_" -Danger
        throw
    }
}