<#
.SYNOPSIS

Converts Windows Compatibility Appraiser BIN files to Human Readable XML files

.DESCRIPTION

Converts Windows Compatibility Appraiser BIN files to Human Readable XML files

Author
    Adam Gross
    @AdamGrossTX
    http://www.asquaredozen.com
    https://github.com/AdamGrossTX
    https://twitter.com/AdamGrossTX


.PARAMETER DeviceName

DeviceName of a remote computer. Defaults to local computer if not specified

.PARAMETER OutputFilePath

Path where all results are stored. Default to c:\Temp.

.PARAMETER BinFilePath

Path to specific BIN files that need to be processed. Defaults to c:\Windows\appcompat\appraiser\ if not specified

.PARAMETER ProcessPantherLogs

Switch parameter to look in any Panther locations for existing XML files to process


.EXAMPLE

Process BIN files from c:\Windows\appcompat\appraiser\ on the current computer and output to the default location of c:\Temp

.\Get-FeatureUpdateBlocks.ps1

.EXAMPLE

Process BIN files from c:\Windows\appcompat\appraiser\ on a remote computer and output to custom location of C:\MyDir

.\Get-FeatureUpdateBlocks.ps1 -DeviceName "MyDevice" -OutputFilePath "C:\MyDir"

.EXAMPLE

Process BIN files from c:\Windows\appcompat\appraiser\ on a remote computer and output to custom location of C:\MyDir and process any Panther logs that may exist on the device

.\Get-FeatureUpdateBlocks.ps1 -DeviceName "MyDevice" -OutputFilePath "C:\MyDir" -ProcessPantherLogs
 
.EXAMPLE

Process BIN files for a remote computer and output to custom location of C:\MyDir and process any Panther logs that may exist on the device and uses bin files from c:\MyBinFiles instead of the default locations

.\Get-FeatureUpdateBlocks.ps1 -DeviceName "MyDevice" -OutputFilePath "C:\MyDir" -ProcessPantherLogs -BinFilePath "C:\MyBinFiles"


.LINK

#Original Source
#https://gallery.technet.microsoft.com/scriptcenter/APPRAISE-APPRAISERbin-to-8399c0ee#content

#Main Blog Post
http://www.asquaredozen.com/2018/07/29/configuring-802-1x-authentication-for-windows-deployment/

#>
Set-Location "C:\Users\grossac\OneDrive - A Square Dozen\GitHub\FU.WhyAmIBlocked"

$ModuleName = "FU.WhyAmIBlocked"
$ModulePath = "$($PSScriptRoot)\$($ModuleName)"
$Author = "Adam Gross (@AdamGrossTX)"
$ModuleVersion = '1.0'
$CompanyName = "A Square Dozen"
$Description = ""
$PrivatePS1Files = (Get-ChildItem -Path ("$ModulePath\Private\*.ps1") -Recurse)
$PublicPS1Files = (Get-ChildItem -Path ("$ModulePath\Public\*.ps1") -Recurse)
$AllPS1Files = (Get-ChildItem -Path ("$ModulePath\*.ps1") -Recurse)
$RootFiles = (Get-ChildItem -Path ("$ModulePath\*.*") -File)
$AllItems = $AllPS1Files + $RootFiles
$BuildDate = Get-Date
$Prefix = "fu"


ForEach ($item in $AllItems) {
    $item.LastWriteTime = $BuildDate;
}

$Manifest = @{
    Path = "$ModulePath\$($ModuleName).psd1"
    RootModule = "$($ModuleName).psm1"
    Author = $Author
    CompanyName = $CompanyName
    ModuleVersion = $ModuleVersion
    Description = $Description
    FunctionsToExport = $PrivatePS1Files.BaseName + $PublicPS1Files.BaseName
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    DscResourcesToExport = @()
    DefaultCommandPrefix = $Prefix.ToUpper()
}

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-modulemanifest?view=powershell-7
New-ModuleManifest @Manifest

$ModuleFunctionScript = "
    `$Public = @(Get-ChildItem -Path `$(`$PSScriptRoot)\Public\*.ps1 -ErrorAction SilentlyContinue)
    `$Private = @(Get-ChildItem -Path `$(`$PSScriptRoot)\Private\*.ps1 -ErrorAction SilentlyContinue)
    `$Prefix = `"$($Prefix)`"
    `$cfg = Get-Content `"`$(`$env:USERPROFILE)\.$($Prefix)cfgpath`" -ErrorAction SilentlyContinue
    `$script:tick = [char]0x221a

    if (`$cfg) {
        `$script:$($Prefix)Config = if (Get-Content -Path `$cfg -raw -ErrorAction SilentlyContinue) {
            Get-Content -Path `$cfg -raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        }
        else {
            `$script:$($Prefix)Config = `$null
        }
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

$ModuleFunctionScript | Out-File -FilePath "$($ModulePath)\$($ModuleName).psm1" -Encoding utf8 -Force