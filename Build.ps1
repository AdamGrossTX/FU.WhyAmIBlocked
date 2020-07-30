[cmdletbinding()]
param (
    [parameter(Mandatory = $true)]
    [System.IO.FileInfo]$modulePath,

    [parameter(Mandatory = $false)]
    [switch]$buildLocal
)

try {

    $ModuleName = "FU.WhyAmIBlocked"
    $Author = "Adam Gross (@AdamGrossTX)"
    $CompanyName = "A Square Dozen"
    $Prefix = "fu"
    $Path = "C:\FeatureUpdateBlocks"
    $ProjectUri = "https://github.com/AdamGrossTX/FU.WhyAmIBlocked"
    $LicenseUri = "https://github.com/AdamGrossTX/FU.WhyAmIBlocked/blob/master/LICENSE"
    $GUID = "48c4fc69-d15f-4dd6-a3af-da65364e03fe"
    $tags = @("Compatilibty","Appraiser","Feature Update","Hard Block")

    
    #region Generate a new version number
    $moduleName = Split-Path -Path $modulePath -Leaf
    $PreviousVersion = Find-Module -Name $moduleName -ErrorAction SilentlyContinue | Select-Object *
    [Version]$exVer = $PreviousVersion ? $PreviousVersion.Version : $null
    if ($buildLocal) {
        $rev = ((Get-ChildItem -Path "$($PSScriptRoot)\bin\release\" -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
        $newVersion = New-Object -TypeName Version -ArgumentList 1, 0, 0, $rev
    }
    else {
        $newVersion = if ($exVer) {
            $rev = ($exVer.Revision + 1)
            New-Object version -ArgumentList $exVer.Major, $exVer.Minor, $exVer.Build, $rev
        }
        else {
            $rev = ((Get-ChildItem "$($PSScriptRoot)\bin\release\" -ErrorAction SilentlyContinue).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
            New-Object Version -ArgumentList 1, 0, 0, $rev 
        }
    }
    $releaseNotes = (Get-Content ".\$($moduleName)\ReleaseNotes.txt" -Raw -ErrorAction SilentlyContinue).Replace("{{NewVersion}}",$newVersion)
    if ($PreviousVersion) {
        $releaseNotes = @"
$releaseNotes
$($previousVersion.releaseNotes)
"@
     
    }
    #endregion



    #region Build out the release
    $relPath = "$($PSScriptRoot)\bin\release\$($rev)\$($moduleName)"
    "Version is $($newVersion)"
    "Module Path is $($modulePath)"
    "Module Name is $($moduleName)"
    "Release Path is $($relPath)"
    if (!(Test-Path -Path $relPath)) {
        New-Item -Path $relPath -ItemType Directory -Force | Out-Null
    }

    Copy-Item -Path "$($modulePath)\*" -Destination "$($relPath)" -Recurse -Exclude ".gitKeep","releaseNotes.txt","description.txt","*.psm1","*.psd1"

    $Manifest = @{
        Path = "$($relPath)\$($ModuleName).psd1"
        RootModule = "$($ModuleName).psm1"
        GUID = $GUID
        Author = $Author
        CompanyName = $CompanyName
        ModuleVersion = $newVersion
        Description = (Get-Content ".\$($moduleName)\description.txt" -raw).ToString()
        FunctionsToExport = (Get-ChildItem -Path ("$($ModulePath)\Public\*.ps1") -Recurse).BaseName
        DefaultCommandPrefix = $Prefix.ToUpper()
        CmdletsToExport = @()
        VariablesToExport = '*'
        AliasesToExport = @()
        DscResourcesToExport = @()
        ReleaseNotes = $releaseNotes
        ProjectUri = $ProjectUri
        LicenseUri = $LicenseUri
        Tags = $Tags
    }

    #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-modulemanifest?view=powershell-7
    New-ModuleManifest @Manifest

$ModuleFunctionScript = "
    `$Public = @(Get-ChildItem -Path `"`$(`$PSScriptRoot)\Public\*.ps1`" -ErrorAction SilentlyContinue)
    `$Private = @(Get-ChildItem -Path `"`$(`$PSScriptRoot)\Private\*.ps1`" -ErrorAction SilentlyContinue)
    `$script:Prefix = `"$($Prefix)`"
    `$script:Path = `"$($Path)`"
    `$initCfg = @{
        Path = `"`$(`$script:Path)`"
        ConfigFile = `"`$(`$script:Path)\Config.json`"
        SDBUnPackerFile = Join-Path -Path `$PSScriptRoot -ChildPath `"SDBUnpacker.py`"
        sdb2xmlPath = Join-Path -Path `$PSScriptRoot -ChildPath `"sdb2xml.exe`"
        UserConfigFile = `"`$(`$env:USERPROFILE)\.`$(`$script:Prefix)cfgpath`"
        PythonPath = `$env:Path.split(';') | Where-Object {`$_ -Like `"*Python*`" -and `$_ -notlike `"*scripts*`"}
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


    If(`$Script:Config.PythonPath -and (Test-Path -Path `"`$(`$Script:Config.PythonPath)`")) {
        `$PythonVersion = & `"`$(`$Script:Config.PythonPath)\python.exe`" --version
    }
    Else {
        `$PythonVersion = & python --version
    }

    If(`$pythonVersion) {
        [switch]`$script:PythonInstalled = `$true
    }
    Else {
        Throw `"Python is not installed. Install Python before proceeding.`"
    }
    
"
   $ModuleFunctionScript | Out-File -FilePath "$($relPath)\$($ModuleName).psm1" -Encoding utf8 -Force
    
    #endregion
    #region Generate a list of public functions and update the module manifest
    #$functions = @(Get-ChildItem -Path $relPath\Public\*.ps1 -ErrorAction SilentlyContinue).basename
    #$params = @{
    #    Path = "$relPath\$ModuleName.psd1"
    #    ModuleVersion = $newVersion
    #    Description = (Get-Content .\$moduleName\description.txt -raw).ToString()
    #    FunctionsToExport = $functions
    #    ReleaseNotes = $releaseNotes.ToString()
    #}
    #Update-ModuleManifest @params
    #endregion
}
catch {
    $_
}
