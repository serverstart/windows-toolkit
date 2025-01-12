Get-ChildItem -Path "./functions/" -Filter "*.ps1" -Recurse | ForEach-Object { . $_.FullName }

Begin-Task "WVD-Key for Teams"
Write-Log "Hallo"
Complete-Task

Begin-Task "Enable App Side-Loading"  # Hier geändert
Write-Log "Hallo"
Complete-Task

Begin-Task "Install required packages"  # Hier geändert
Install-WinGetPackage -AppIDs "Microsoft.VCRedist.2015+.x64","Microsoft.VCRedist.2015+.x86","Microsoft.EdgeWebView2Runtime" -AllowUpgrade

Write-Log "Install Microsoft.VCRedist.2015+.x86"
Write-Log "Install Microsoft.EdgeWebView2Runtime"
Complete-Task
