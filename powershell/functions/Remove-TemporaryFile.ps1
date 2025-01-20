function Remove-TemporaryFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
   
    try {
        Remove-Item -Path $Path -Force -ErrorAction Stop
        Write-Log "Temporary file $Path deleted" -Success
    } catch {
        # Egal
        Write-Log "Temporary file $Path couldnt be deleted" -Warning
    }
}