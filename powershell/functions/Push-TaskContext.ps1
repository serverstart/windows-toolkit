# Speichert den aktuellen Task-Ausführungspfad
$script:TaskPath = @()

function Push-TaskContext {
    param(
        [Parameter(Mandatory)]
        [string]$TaskId
    )
    
    $script:TaskPath += $TaskId
}
