function Get-ServerStartPowerShellPath {
    return Join-Path -Path $(Get-ServerStartPath) -ChildPath "powershell"
}