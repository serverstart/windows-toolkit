function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Value,
        [switch]$Success,
        [switch]$Warning, 
        [switch]$Danger,
        [switch]$Info,
        [switch]$PrefixNewline,
        [switch]$SuffixNewline
    )
 
    if ($PrefixNewline) {
        Write-Host ""
    }
 
    $color = if ($Success) { 'Green' }
    elseif ($Warning) { 'Yellow' }
    elseif ($Info) { 'Cyan' }
    elseif ($Danger) { 'Red' }
    else { 'White' }
 
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Wenn es aktive Tasks gibt, zeige den Task-Pfad an
    if ($script:TaskPath.Count -gt 0) {
        # Hole die Namen der aktiven Tasks aus ActiveTasks anhand der IDs im TaskPath
        $taskNames = $script:TaskPath | ForEach-Object { 
            $script:ActiveTasks[$_].Name 
        }
        $taskPathDisplay = $taskNames -join " > "
        Write-Host "[$timestamp, $taskPathDisplay] $Value" -ForegroundColor $color
    } else {
        Write-Host "[$timestamp] $Value" -ForegroundColor $color 
    }

    if ($SuffixNewline) {
        Write-Host ""
    }
}