# FU.WhyAmIBlocked

[![Build Status](https://dev.azure.com/ASquareDozen/FU.WhyAmIBlocked/_apis/build/status/AdamGrossTX.FU.WhyAmIBlocked?branchName=master)](https://dev.azure.com/ASquareDozen/FU.WhyAmIBlocked/_build/latest?definitionId=1&branchName=master)

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
If you want to use the module from the repo, you will need to build it first. It will be output to `.\bin\release\FU.WhyAmIBlocked`

``` PowerShell
.\Build.ps1 -ModulePath .\FU.WhyAmIBlocked
Import-Module ".\bin\release\FU.WhyAmIBlocked" -Force
```

## Additional commands

### Create config file. 

If you need to customize paths, run this command. This creates a configfile in `C:\FeatureUpdateBlocks\fuconfig.json` that you can edit as needed.
```
Initialize-FUModule 
```

### Convert appraiser bin files to XML
If you have .bin files collected in a folder already, you can process them. OutputPath must exist before running the command.

```
ConvertFrom-BinToXML -FileList @("c:\temp\myfile1.bin","c:\temp\myfile2.bin") -OutputPath "C:\temp\"
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
Export-BypassBlock -Path "c:\temp"
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
C:\FeatureUpdateBlocks\*_matches.json
C:\FeatureUpdateBlocks\*_matches.txt
C:\FeatureUpdateBlocks\*_BypassFUBlock.reg
C:\FeatureUpdateBlocks\*_BypassFUBlock.ps1
C:\FeatureUpdateBlocks\*_<ver>.XML
```
All other files/folders are named based on their original folder structure and file names.
```

<SourceParentFolder1>_<SourceParentFolder2><ver>_<filename>
example:
AppCompatAppraiser_2379_Appraiser_AlternateData.cab
```




## Resources used

- https://github.com/TheEragon/SdbUnpacker
- https://devblogs.microsoft.com/setup/shim-database-to-xml/
- https://gallery.technet.microsoft.com/scriptcenter/APPRAISE-APPRAISERbin-to-8399c0ee
