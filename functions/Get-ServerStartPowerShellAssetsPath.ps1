function Get-ServerStartPowerShellAssetsPath {
    return Join-Path -Path $(Get-ServerStartPowerShellPath) -ChildPath "assets"
}