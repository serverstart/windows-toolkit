function Invoke-TemporaryFileDownload {
    param(
        [Parameter(Mandatory)]
        [string]$Url,
        
        [Parameter()]
        [string]$Filename
    )
   
    try {
        Write-Log "Downloading file from: $Url"

        $request = [System.Net.WebRequest]::Create($Url)
        $response = $request.GetResponse()
        $realUrl = $response.ResponseUri.AbsoluteUri
        $response.Dispose()

        if (-not $Filename) {
            $Filename = [System.IO.Path]::GetFileName($realUrl)
            if ([string]::IsNullOrEmpty($Filename)) {
                $Filename = [System.IO.Path]::GetRandomFileName()
            }
        }

        $fullPath = Join-Path $env:TEMP $Filename
        Start-BitsTransfer -Source $Url -Destination $fullPath
        
        Write-Log "Download successful: $fullPath" -Success

        return $fullPath
    } catch {
        Write-Log "Failed to download file: $_" -Danger
        throw
    }
}