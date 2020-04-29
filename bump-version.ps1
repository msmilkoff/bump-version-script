$ErrorActionPreference = "Stop"

$newLine = [System.Environment]::NewLine

$versionFileName = "VERSION"
$versionRegex = "^(\d+\.)?(\d+\.)?(\*|\d+)$"
$versionFilePath = "$($PSScriptRoot)/$($versionFileName)"
$version = New-Object System.Version(1, 0, 0)

if(!(Test-Path $versionFilePath -PathType Leaf)) {
    Write-Host "No previous versions found.`r`nPlease enter an initial version number in format {major}.{minor}.{patch}"
    Write-Host "Default is: " -NoNewline
    Write-Host "[1.0.0]" -ForegroundColor DarkGreen

    # Prompt the user to enter a new initial version number
    $input = Read-Host
    if (-not([string]::IsNullOrWhiteSpace($input))) {
        while (!($input -match  "^(\d+\.)?(\d+\.)?(\*|\d+)$")) {
            Write-Host "Invalid version number`r`rPlease enter a version number in format {major}.{minor}.{patch} eg: " -NoNewline
            Write-Host "1.0.0" -ForegroundColor DarkGreen
            
            $input = Read-Host
        }

        $version = New-Object System.Version($input);
    }

    # Create the new VERSION file
    New-Item -Path $PSScriptRoot -Name $versionFileName -ItemType "file" -Value $version.ToString()
    Write-Host "$($versionFileName) file created."
    Write-Host "Initial version set to $($version)"

    Set-Location $PSScriptRoot
    git add $versionFileName
} else {
    $fileContent = [System.IO.File]::ReadAllText($versionFilePath)
    if (-not($fileContent -match $versionRegex)) {
        Write-Host "Fatal: The version file is corrupted" -ForegroundColor Red
        exit
    }

    $version = New-Object System.Version($fileContent)

    #Suggest a 'minor' version update
    $newVersion = New-Object System.Version($version.Major, ($version.Minor +1 ), 0)
    Write-Host "Specify new version"
    Write-Host "Default is: " -NoNewline
    Write-Host "[$($newVersion.ToString())]" -ForegroundColor DarkGreen

    $input = Read-Host
    if (-not([string]::IsNullOrWhiteSpace($input))) {
        while (!($input -match  "^(\d+\.)?(\d+\.)?(\*|\d+)$")) {
            Write-Host "Invalid version number`r`rPlease enter a version number in format {major}.{minor}.{patch} eg : " -NoNewline
            Write-Host "1.0.0" -ForegroundColor DarkGreen
            
            $input = Read-Host
        }

        $newVersion = New-Object System.Version($input);
    }

    $version = $newVersion;

    [System.IO.File]::WriteAllText($versionFilePath, $version.ToString());
}

$changelogFileName = "CHANGELOG.md"
$changelogFilePath = "$($PSScriptRoot)/$($changelogFileName)"
if(!(Test-Path $changelogFilePath -PathType Leaf)) {
    New-Item -Path $PSScriptRoot -Name $changelogFileName -ItemType "file"
    Write-Host "Changelog file created"

    Set-Location $PSScriptRoot
    git add $changelogFileName
}

$oldChangeLogContent = [System.IO.File]::ReadAllText($changelogFilePath)
$newChangeLogContent  = "## New in Version $($version.ToString()) $($newLine)$($newLine)$($oldChangeLogContent)"
[System.IO.File]::WriteAllText($changelogFilePath, $newChangeLogContent);

Write-Host "[Optional]" -ForegroundColor DarkYellow
Write-Host "You can now make adjustments to the $($changelogFileName) file if you wish and press enter"
Read-Host

$bumpMsg = "Bumped version to [$($version.ToString())]"
Set-Location $PSScriptRoot
git add $versionFileName
git add $changelogFileName
git commit -m $bumpMsg
git tag -a -m "Tag version $($version.ToString())" "v$($version.ToString())"
git push origin --tags

Write-Host $bumpMsg
