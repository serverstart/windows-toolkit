function Get-AppXPackageVersion {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )
    
    $app = Get-AppxPackage -Name "*$PackageName*" -AllUsers
    
    if ($app) {
        if ($app.Version -eq "1.0.0.0") {
            return "NOT_INSTALLED"
        } else {
            return $app.Version
        }
    } else {
        return "NOT_INSTALLED"
    }
}