
function Pop-TaskContext { 
    if ($script:TaskPath.Count -gt 0) {
        $script:TaskPath = @($script:TaskPath | Select-Object -SkipLast 1)
    }
}