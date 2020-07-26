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
```

Once module is installed Initialize and run commands..

``` PowerShell
Initialize-FUModule
Get-FUBlocks
```

## Build from source

``` PowerShell
.\Build.ps1 -ModulePath .\FU.WhyAmIBlocked -BuildLocal
Import-Module ".\bin\release\*\FU.WhyAmIBlocked" -Force #replace the * with release number generated from build.
```

## Resources used

- SDBUnpacker.py sourced from https://github.com/TheEragon/SdbUnpacker
- sdb2XML sourced from https://devblogs.microsoft.com/setup/shim-database-to-xml/
