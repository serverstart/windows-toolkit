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
 
    $breadcrumbPath = $script:Breadcrumbs -join " > ";
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss";

    if($script:Breadcrumbs.Count -gt 0) {
        $breadcrumbPath = $script:Breadcrumbs -join " > "
        Write-Host "[$timestamp, $breadcrumbPath] $Value" -ForegroundColor $color
     } else {
        Write-Host "[$timestamp] $Value" -ForegroundColor $color 
     }

    if ($SuffixNewline) {
        Write-Host ""
    }
 }