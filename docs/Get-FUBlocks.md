---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Get-FUBlocks

## SYNOPSIS
Collects compatibility appraiser files from local or remote machine and exports a block list from the appraiser db.

## SYNTAX

### Local (Default)
```
Get-FUBlocks [-Local] [-RunCompatAppraiser] [[-AlternateSourcePath] <String>] [[-Path] <String>]
 [-ProcessPantherLogs] [-SkipSDBInfo] [<CommonParameters>]
```

### Alt
```
Get-FUBlocks [[-DeviceName] <String>] [-AlternateSourcePath] <String> [[-Path] <String>] [-ProcessPantherLogs]
 [-SkipSDBInfo] [<CommonParameters>]
```

### Remote
```
Get-FUBlocks [-DeviceName] <String> [[-AlternateSourcePath] <String>] [[-Path] <String>] [-ProcessPantherLogs]
 [-SkipSDBInfo] [<CommonParameters>]
```

## DESCRIPTION
Collects compatibility appraiser files from local or remote machine and exports a block list from the appraiser db.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-FUBlocks
```

Processes data from default locations on the local device.

## PARAMETERS

### -AlternateSourcePath
Alternate path with Appraiser_AlternateData.Cab and .bin files for processing

```yaml
Type: String
Parameter Sets: Local, Remote
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Alt
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceName
The name of the device to remotely connect to for data

```yaml
Type: String
Parameter Sets: Alt
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Remote
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Local
Uses local device as the data source.

```yaml
Type: SwitchParameter
Parameter Sets: Local
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Output/Working path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessPantherLogs
Optional - pick up panther logs from a failed feature update and process them.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RunCompatAppraiser
Launches the compatibilty appraiser scheduled task on the local machine (doesn't work on remote)

```yaml
Type: SwitchParameter
Parameter Sets: Local
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipSDBInfo
Skip processing the files against the appraiser database. 

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
