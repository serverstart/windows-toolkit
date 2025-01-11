$script:Breadcrumbs = @()

function Add-Breadcrumb {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )
    
    $script:Breadcrumbs += $Value
}

