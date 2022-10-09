---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Find-FUBlocksInSDB

## SYNOPSIS
Searches the SDB for the GUIDs of any blocked items and outputs Matches.txt and AllMatches.json

## SYNTAX

```
Find-FUBlocksInSDB [[-Path] <String>] [[-BlockList] <String[]>] [<Commonparameters>]
```

## DESCRIPTION
Searches the SDB for the GUIDs of any blocked items and outputs Matches.txt and AllMatches.json

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-FUBlocksInSDB -BlockList @('{GUID1},{GUID2}') -Path C:\FeatureUpdateBlocks\PathToSdbXML
```

Extract a list of blocks from the SDB using a list of GUIDs. Great option if you've used CMPivot to gather a list from the registry.

## PARAMETERS

### -BlockList
List of blocked GUIDs

```yaml
Type: String[]
parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path where the extracted SDB XML exists

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
