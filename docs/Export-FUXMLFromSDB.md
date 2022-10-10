---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Export-FUXMLFromSDB

## SYNOPSIS
Converts a decompressed SDB file to XML.

## SYNTAX

```
Export-FUXMLFromSDB [[-Path] <String>] [[-AlternateSourcePath] <String>] [<Commonparameters>]
```

## DESCRIPTION
Converts a decompressed SDB file to XML.

## EXAMPLES

### Example 1
```
PS C:\> Export-FUXMLFromSDB -AlternateSourcePath c:\AltSourcePath\
```

Exports the SDB from an alternate source path

## PARAMETERS

### -AlternateSourcePath
The path containing a .sdb file and/or Appraiser_AlternateData.cab

```yaml
Type: String
parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Output/working path

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
