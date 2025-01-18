function Get-ServerStartPowerShellScriptsPath {
    return Join-Path -Path $(Get-ServerStartPowerShellPath) -ChildPath "assets"
}