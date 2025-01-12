function Complete-Task {
    $taskId = $script:TaskPath | Select-Object -Last 1
    if ([string]::IsNullOrEmpty($taskId) -or -not $script:ActiveTasks.ContainsKey($taskId)) {
        Write-Log "Fehler: Keine aktive Task gefunden" -Danger
        return
    }

    $taskInfo = $script:ActiveTasks[$taskId]
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $taskInfo.StartTime -End $endTime
    
    Write-Log "--- Finished $($taskInfo.Name) (Duration: $($duration.TotalSeconds.ToString('0.000')) seconds) ---" -Info -SuffixNewline
    $script:ActiveTasks.Remove($taskId)
    Pop-TaskContext
}
