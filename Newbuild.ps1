[cmdletbinding()]
param (
    [parameter(Mandatory = $true)]
    [System.IO.FileInfo]$modulePath,

    [parameter(Mandatory = $false)]
    [switch]$buildLocal
)
try {
    #region Generate a new version number
    $moduleName = Split-Path $modulePath -Leaf
    [Version]$exVer = Find-Module $moduleName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
    if ($buildLocal) {
        $rev = ((Get-ChildItem $PSScriptRoot\bin\release\ -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
        $newVersion = New-Object Version -ArgumentList 1, 0, 0, $rev
    }
    else {
        $newVersion = if ($exVer) {
            $rev = ($exVer.Revision + 1)
            New-Object version -ArgumentList $exVer.Major, $exVer.Minor, $exVer.Build, $rev
        }
        else {
            $rev = ((Get-ChildItem $PSScriptRoot\bin\release\ -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
            New-Object Version -ArgumentList 1, 0, 0, $rev

        }
    }
    $releaseNotes = (Get-Content .\$moduleName\ReleaseNotes.txt -Raw -ErrorAction SilentlyContinue).Replace("{{NewVersion}}",$newVersion)
    $releaseNotes = $exVer ? $releaseNotes.Replace("{{LastVersion}}","$($exVer.ToString())") : $releaseNotes.Replace("{{LastVersion}}","")
    #endregion
    #region Build out the release
    $relPath = "$PSScriptRoot\bin\release\$rev\$moduleName"
    "Version is $newVersion"
    "Module Path is $modulePath"
    "Module Name is $moduleName"
    "Release Path is $relPath"
    if (!(Test-Path $relPath)) {
        New-Item -Path $relPath -ItemType Directory -Force | Out-Null
    }
    Copy-Item "$modulePath\*" -Destination "$relPath" -Recurse -Exclude ".gitKeep","releaseNotes.txt","description.txt"
    #endregion
    #region Generate a list of public functions and update the module manifest
    $functions = @(Get-ChildItem -Path $relPath\Public\*.ps1 -ErrorAction SilentlyContinue).basename
    $params = @{
        Path = "$relPath\$ModuleName.psd1"
        ModuleVersion = $newVersion
        Description = (Get-Content .\$moduleName\description.txt -raw).ToString()
        FunctionsToExport = $functions
        ReleaseNotes = $releaseNotes.ToString()
    }
    Update-ModuleManifest @params
    #endregion
}
catch {
    $_
}