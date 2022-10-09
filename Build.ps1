[cmdletbinding()]
param (
    [parameter(Mandatory = $false)]
    [System.IO.FileInfo]$modulePath = "$PSScriptRoot\FU.WhyAmIBlocked",

    [parameter(Mandatory = $false)]
    [switch]$buildLocal
)

try {

    $ModuleName = "FU.WhyAmIBlocked"
    $Author = "Adam Gross (@AdamGrossTX)"
    $CompanyName = "A Square Dozen"
    $Path = "C:\FeatureUpdateBlocks"
    $ProjectUri = "https://github.com/AdamGrossTX/FU.WhyAmIBlocked"
    $LicenseUri = "https://github.com/AdamGrossTX/FU.WhyAmIBlocked/blob/master/LICENSE"
    $GUID = "48c4fc69-d15f-4dd6-a3af-da65364e03fe"
    $tags = @("Compatibility", "Appraiser", "FeatureUpdate", "HardBlock")

    
    #region Generate a new version number
    $moduleName = Split-Path -Path $modulePath -Leaf
    $PreviousVersion = Find-Module -Name $moduleName -ErrorAction SilentlyContinue | Select-Object *
    [Version]$exVer = If ($PreviousVersion) { $PreviousVersion.Version } Else { $null }

    if ($buildLocal) {
        $rev = ((Get-ChildItem -Path "$PSScriptRoot\bin\release\" -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
        $newVersion = New-Object -TypeName Version -ArgumentList 1, 0, 0, $rev
    }
    else {
        $newVersion = if ($exVer) {
            $rev = ($exVer.Revision + 1)
            New-Object version -ArgumentList $exVer.Major, $exVer.Minor, $exVer.Build, $rev
        }
        else {
            $rev = ((Get-ChildItem "$PSScriptRoot\bin\release\" -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
            New-Object Version -ArgumentList 1, 0, 0, $rev
        }
    }
    $releaseNotes = (Get-Content ".\$($moduleName)\ReleaseNotes.txt" -Raw -ErrorAction SilentlyContinue).Replace("{{NewVersion}}", $newVersion)
    if ($PreviousVersion) {
        $releaseNotes = @"
$releaseNotes
$($previousVersion.releaseNotes)
"@
     
    }
    #endregion

    #region Build out the release
    $relPath = "$($PSScriptRoot)\bin\release\$($rev)\$($moduleName)"   
    if ($buildLocal) {
        $relPath = "$PSScriptRoot\bin\release\$rev\$moduleName"
    }
    else {
        $relPath = "$PSScriptRoot\bin\release\$moduleName"
    }
    "Version is $($newVersion)"
    "Module Path is $($modulePath)"
    "Module Name is $($moduleName)"
    "Release Path is $($relPath)"
    if (!(Test-Path -Path $relPath)) {
        New-Item -Path $relPath -ItemType Directory -Force | Out-Null
    }

    If (Test-Path $relPath) {
        #Remove-Item -Path "$($relPath)\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -Path "$($modulePath)\*" -Destination "$($relPath)" -Recurse -Exclude ".gitKeep", "releaseNotes.txt", "description.txt", "*.psm1", "*.psd1" -Force

    $Manifest = @{
        Path                 = "$($relPath)\$($ModuleName).psd1"
        RootModule           = "$($ModuleName).psm1"
        GUID                 = $GUID
        Author               = $Author
        CompanyName          = $CompanyName
        ModuleVersion        = $newVersion
        Description          = (Get-Content ".\$($moduleName)\description.txt" -raw).ToString()
        FunctionsToExport    = (Get-ChildItem -Path ("$($ModulePath)\Public\*.ps1") -Recurse).BaseName
        CmdletsToExport      = @()
        VariablesToExport    = '*'
        AliasesToExport      = @()
        DscResourcesToExport = @()
        ReleaseNotes         = $releaseNotes
        ProjectUri           = $ProjectUri
        LicenseUri           = $LicenseUri
        Tags                 = $Tags
    }

    #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-modulemanifest?view=powershell-7
    New-ModuleManifest @Manifest

    $ModuleFunctionScript = "

#region mainscript
    `$Public = @(Get-ChildItem -Path `"`$(`$PSScriptRoot)\Public\*.ps1`" -ErrorAction SilentlyContinue)
    `$Private = @(Get-ChildItem -Path `"`$(`$PSScriptRoot)\Private\*.ps1`" -ErrorAction SilentlyContinue)
    `$script:Path = `"$($Path)`"
       
    `$initCfg = @{
        Path = `"`$(`$script:Path)`"
        AutoUpdate = `$false
        ConfigFile = `"`$(`$script:Path)\Config.json`"
        SDBUnPackerFile = Join-Path -Path `$PSScriptRoot -ChildPath `"SDBUnpacker.py`"
        sdb2xmlPath = Join-Path -Path `$PSScriptRoot -ChildPath `"sdb2xml.exe`"
        UserConfigFile = `"`$(`$env:USERPROFILE)\.`$(`$script:Prefix)cfgpath`"
    }
    `$cfg = Get-Content `$initCfg[`"UserConfigFile`"] -ErrorAction SilentlyContinue
    `$script:tick = [char]0x221a

    if (`$cfg) {
        if (Get-Content -Path `$cfg -raw -ErrorAction SilentlyContinue) {
            `$script:Config = Get-Content -Path `$cfg -raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        }
        else {
            `$script:Config = `$initCfg
        }
    }
    else {
        `$script:Config = `$initCfg
    }
    #endregion

    #region Dot source the files
    foreach (`$import in @(`$Public + `$Private)) {
        try {
            . `$import.FullName
        }
        catch {
            Write-Error -Message `"Failed to import function `$(`$import.FullName): `$_`"
        }
    }
    #endregion
 
"
    $ModuleFunctionScript | Out-File -FilePath "$($relPath)\$($ModuleName).psm1" -Encoding utf8 -Force

}
catch {
    $_
}
