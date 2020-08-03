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
    $tags = @("Compatilibty","Appraiser","FeatureUpdate","HardBlock")

    
    #region Generate a new version number
    $moduleName = Split-Path -Path $modulePath -Leaf
    $PreviousVersion = Find-Module -Name $moduleName -ErrorAction SilentlyContinue | Select-Object *
    [Version]$exVer = If($PreviousVersion) {$PreviousVersion.Version} Else {$null}

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

    If(Test-Path $relPath) {
        #Remove-Item -Path "$($relPath)\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Copy-Item -Path "$($modulePath)\*" -Destination "$($relPath)" -Recurse -Exclude ".gitKeep","releaseNotes.txt","description.txt","*.psm1","*.psd1" -Force

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
    `$pythonPath = `$env:Path.split(';') | Where-Object {`$_ -Like `"*Python*`" -and `$_ -notlike `"*scripts*`"}


       
    `$initCfg = @{
        Path = `"`$(`$script:Path)`"
        ConfigFile = `"`$(`$script:Path)\Config.json`"
        SDBUnPackerFile = Join-Path -Path `$PSScriptRoot -ChildPath `"SDBUnpacker.py`"
        sdb2xmlPath = Join-Path -Path `$PSScriptRoot -ChildPath `"sdb2xml.exe`"
        UserConfigFile = `"`$(`$env:USERPROFILE)\.`$(`$script:Prefix)cfgpath`"
        PythonPath = If(`$pythonPath) {`$pythonPath} Else {`"`"}
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


    `$PythonExe = If(`$script:Config.PythonPath) {
                    If(Test-Path (Join-Path `$script:Config.PythonPath -ChildPath `"python.exe`") -ErrorAction SilentlyContinue) {
                            Join-Path `$script:Config.PythonPath -ChildPath `"python.exe`"
                        }
                        Else {
                            `"python.exe`"
                        }
                    }
                    Else {
                        `"python.exe`"
     }
 
     try {
         `$PythonVersion = & `"`$(`$PythonExe)`" --version 2>&1 | ForEach-Object { `"`$_`" }
     }
     catch {
 
     }
 
     If(!(`$PythonVersion)) {
         `$script:Config.PythonPath = `"`$(Read-Host -Prompt `"Enter the folder path to python.exe`")`"
         If(`$script:Config.PythonPath) {
             `$PythonExe = Join-Path `$script:Config.PythonPath -ChildPath `"python.exe`"
             If(!(Test-Path -Path `$PythonExe -ErrorAction SilentlyContinue)) {
                 `$script:Config.PythonPath = `$null
             }
             Else {
                 `$PythonExe = Join-Path `$script:Config.PythonPath -ChildPath `"python.exe`"
                 `$PythonVersion = & `"`$(`$PythonExe)`" --version 2>&1 | ForEach-Object { `"`$_`" }
                 If(`$PythonVersion) {
                     Write-Host `" *** Run 'Initialize-FUModule -reset' to save the Python path to your config file.`" -foregroundcolor green
                 }
             }
         }
         Else {
             Write-Warning `"No Python Path was entered. Skipping.`"
         }
     }
 
     If(`$pythonVersion) {
         [switch]`$script:PythonInstalled = `$true
         `$initCfg.PythonPath = `$script:Config.PythonPath
         `$script:PythonExe = `$PythonExe
     }
     Else {
         Write-Warning `"Python is not installed. Install Python then re-import the module then run 'Initialize-FUModule -Reset'. 
         You may need to close PowerShell and re-launch after install. `"
         Write-Host  `" + You can install the Windows Store version from here https://www.microsoft.com/store/productId/9MSSZTT1N39L`" -foregroundcolor blue
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
