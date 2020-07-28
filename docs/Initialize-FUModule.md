---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Initialize-FUModule

## SYNOPSIS
Creates the root folder in C:\FeatureUpdates and creates the fuconfig.json file.

## SYNTAX

```
Initialize-FUModule [[-initCfg] <Object>] [-Reset] [<CommonParameters>]
```

## DESCRIPTION
Creates the root folder in C:\FeatureUpdates and creates the fuconfig.json file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Initialize-FUModule
```

Creates the root folder in C:\FeatureUpdates and creates the fuconfig.json file.

### Example 2
```powershell
PS C:\> Initialize-FUModule -reset
```

Resets the config.json

### Example 2
```powershell
PS C:\> 
    $initCfg = @{
        Path = "C:\MyPath"
        ConfigFile = "$($script:Path)\Config.json"
        SDBCab = "Appraiser_AlternateData.cab"
        SDBUnPackerFile = Join-Path -Path $PSScriptRoot -ChildPath "SDBUnpacker.py"
        sdb2xmlPath = Join-Path -Path $PSScriptRoot -ChildPath "sdb2xml.exe"
        UserConfigFile = "$($env:USERPROFILE)\.$($script:Prefix)cfgpath"
        PythonPath = $env:Path.split(';') | Where-Object {$_ -Like "*Python*" -and $_ -notlike "*scripts*"}
    }

    Initialize-FUModule -initCfg $initCfg
```

Initializes the module with custom options

## PARAMETERS

### -Reset
Overwrites the existing json file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -initCfg
Custom configuration option hashtable

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
