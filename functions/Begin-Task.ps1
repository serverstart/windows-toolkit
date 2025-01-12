# Speichert alle aktiven Tasks mit ihren Metadaten
$script:ActiveTasks = @{}

function Begin-Task { 
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    $taskId = [guid]::NewGuid().ToString()
    $script:ActiveTasks[$taskId] = @{
        StartTime = Get-Date
        Name = $Name
    }
    Push-TaskContext $taskId
    Write-Log "--- Start of $Name ---" -Info -PrefixNewline
}
