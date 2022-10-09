---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Export-FUBypassBlock

## SYNOPSIS
if block bypass entries are found in the sdb, registry and ps1 files will be exported for easy use on blocked devices.

## SYNTAX

```
Export-FUBypassBlock [[-Path] <String>] [<Commonparameters>]
```

## DESCRIPTION
if block bypass entries are found in the sdb, registry and ps1 files will be exported for easy use on blocked devices.

## EXAMPLES

### Example 1
```powershell
PS C:\> Export-FUBypassBlock -Path c:\Path\Matches.json
```

Uses the exported json files to generate the files being exported

## PARAMETERS

### -Path
Path to the json file

```yaml
Type: String
parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### Commonparameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_Commonparameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
