---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Export-FUBypassBlock

## SYNOPSIS
If block bypass entries are found in the sdb, registry and ps1 files will be exported for easy use on blocked devices.

## SYNTAX

```
Export-FUBypassBlock [[-InputFile] <String>] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
If block bypass entries are found in the sdb, registry and ps1 files will be exported for easy use on blocked devices.

## EXAMPLES

### Example 1
```powershell
PS C:\> Export-FUBypassBlock -InputFile AllBlocks.json
```

Uses the exported AllBlocks.json to generate the files being exported

## PARAMETERS

### -InputFile
The json output created by the Find-FUBlocksinSDB function

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to the json file

```yaml
Type: String
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
