function Test-AppXPackageInstallation {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    Begin-Task "Test AppX Package Installation"
 
    # Prüfe AppX-Installation für alle Benutzer
    $app = Get-AppxPackage -Name "*$PackageName*" -AllUsers
    $result = "CHECK_ERROR" # Default-Wert

    if ($app) {
        if ($app.Version -eq "1.0.0.0") {
            Write-Host "× $PackageName ist nur in Version 1.0.0.0 verfügbar. Dies wird als Nicht-Installiert gewertet." -ForegroundColor Yellow
            Write-Host "Version: $($app.Version)" -ForegroundColor Yellow
            Write-Host "Installationsort: $($app.InstallLocation)" -ForegroundColor Yellow
            $result = "CHECK_FAILED"
        } else {
            Write-Host "√ $PackageName ist in Version $($app.Version) installiert" -ForegroundColor Green
            Write-Host "Version: $($app.Version)" -ForegroundColor Green
            Write-Host "Installationsort: $($app.InstallLocation)" -ForegroundColor Green
            $result = "CHECK_PASSED"
        }
    } else {
        Write-Host "× $PackageName ist nicht installiert" -ForegroundColor Red
        $result = "CHECK_FAILED"
    }

    Complete-Task
    return $result
}