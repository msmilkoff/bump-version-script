$ErrorActionPreference = "Stop"

$versionFileName = "VERSION"
if(!(Test-Path("./$($versionFileName)"))) {
    Write-Host("Create file " + $versionFileName)
    Write-Host("No previous versions found.`r`nPlease enter an initial version number in format {major}.{minor}.{patch}")
}
