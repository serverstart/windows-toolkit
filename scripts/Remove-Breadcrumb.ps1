function Remove-Breadcrumb { 
    $script:Breadcrumbs = $script:Breadcrumbs | Select-Object -SkipLast 1 
}
