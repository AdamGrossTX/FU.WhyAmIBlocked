---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# Get-FUBlocksFromBin

## SYNOPSIS
Takes .bin files, converts to XML, and outputs Results.txt summary file with a list of blocks.

## SYNTAX

```
Get-FUBlocksFromBin [-FileList] <String[]> [-ResultFile <String>] [<CommonParameters>]
```

## DESCRIPTION
Takes .bin files, converts to XML, and outputs Results.txt summary file with a list of blocks.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-FUBlocksFromBin -FileList @('C:\MySource\MyFile.bin')
```

Converts a list of bin files and gets results

## PARAMETERS

### -FileList
Array of Compatibility Appraiser .Bin files

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResultFile
Path to an alternate Results file. Default is .\Results.txt

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: .\Results.txt
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### -Output = [System.Collections.ArrayList]

### System.Object
## NOTES

## RELATED LINKS
