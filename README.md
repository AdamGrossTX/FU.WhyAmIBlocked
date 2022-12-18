# FU.WhyAmIBlocked

[![Build Status](https://dev.azure.com/ASquareDozenLab/FU.WhyAmIBlocked/_apis/build/status/AdamGrossTX.FU.WhyAmIBlocked?branchName=main)](https://dev.azure.com/ASquareDozenLab/FU.WhyAmIBlocked/_build/latest?definitionId=1&branchName=main)

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/FU.WhyAmIBlocked.svg?style=flat&logo=powershell&label=PSGallery%20Version)

![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/FU.WhyAmIBlocked.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)

## Summary

Can't get the latest Windows 10 Feature update? Need to find out what's blocking you? This module will help you find the block quickly!

## Getting Started

Install module from gallery

``` PowerShell
Install-Module FU.WhyAmIBlocked -Scope CurrentUser
Import-Module FU.WhyAmIBlocked
```

Once module is installed run command to collect data from the local device..

``` PowerShell
Get-FUBlocks
```

Python is required to process the sdb compatibility database, but the module will still function partially without it.

## Build from source
if you want to use the module from the repo, you will need to build it first. It will be output to `.\bin\release\FU.WhyAmIBlocked`

``` PowerShell
.\Build.ps1 -ModulePath .\FU.WhyAmIBlocked
Import-Module ".\bin\release\FU.WhyAmIBlocked" -Force
```

## Additional commands

### Create config file. 

if you need to customize paths, run this command. This creates a configfile in `C:\FeatureUpdateBlocks\fuconfig.json` that you can edit as needed.
```
Initialize-FUModule 
```

### Convert appraiser bin files to XML
if you have .bin files collected in a folder already, you can process them. OutputPath must exist before running the command.

```
ConvertFrom-FUBinToXML -FileList @("c:\temp\myfile1.bin","c:\temp\myfile2.bin") -OutputPath "C:\temp\"
```

### Export SDB to XML
Exracts cab files with sdbs and/or Converts extracted sdb files to XML.
```
Export-FUXMLFromSDB -AlternateSourcePath "c:\temp"
```

### Get blocks from appraiser .bin files
```
Get-FUBlocksFromBin -FileList @("c:\temp\myfile1_humanreadable.xml","c:\temp\myfile2_humanreadable.bin")
```

### Lookup blocks and related blocks in sdb
```
$SdbAppGUIDs = @("{31f134a0-ce2c-4e97-b65d-746d6071bfba}")
Find-FUBlocksInSDB -BlockList $SdbAppGUIDs -Path "c:\temp\"
```

### Create reg and ps1 files to bypass blocks (where available)
Requires `.json` file from `Find-FUBlocksInSDB` to be in the `Path` location.

```
Export-FUBypassBlock -Path "c:\temp"
```



## Folder and files paths
### Default folders/files
```
$env:USERPROFILE\.fucfgpath - Created when module is imported the first time.
C:\FeatureUpdateBlocks
C:\FeatureUpdateBlocks\AppraiserData
C:\FeatureUpdateBlocks\Bin
C:\FeatureUpdateBlocks\CABs
C:\FeatureUpdateBlocks\XML
C:\FeatureUpdateBlocks\Results.txt
```
All other files/folders are named based on their original folder structure and file names.

```
C:\FeatureUpdateBlocks\*_matches.json
C:\FeatureUpdateBlocks\*_matches.txt
C:\FeatureUpdateBlocks\*_BypassFUBlock.reg
C:\FeatureUpdateBlocks\*_BypassFUBlock.ps1
C:\FeatureUpdateBlocks\*_<ver>.XML

<SourceParentFolder1>_<SourceParentFolder2><ver>_<filename>
example:
AppCompatAppraiser_2379_Appraiser_AlternateData.cab
```




## Resources used

- https://github.com/TheEragon/SdbUnpacker
- https://devblogs.microsoft.com/setup/shim-database-to-xml/
- https://gallery.technet.microsoft.com/scriptcenter/APPRAISE-APPRAISERbin-to-8399c0ee

## Troubleshooting

- After running `Install-Module FU.WhyAmIBlocked -Scope CurrentUser` there is a warning message:
> Untrusted repository
> You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
This is normal and can be excepted.

- - After running `Import-Module FU.WhyAmIBlocked` there is a warning message:
> Import-Module : File C:\...\FU.WhyAmIBlocked\1.0.0.9\FU.WhyAmIBlocked.psm1
cannot be loaded because running scripts is disabled on this system. For more information, see
about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.

The MS page suggests 2 commands:
1) `Get-ExecutionPolicy -Scope CurrentUser` gives the current policy set
2) `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` sets the policy

It is then possible to run `Import-Module FU.WhyAmIBlocked` without problems

