---
external help file: FU.WhyAmIBlocked-help.xml
Module Name: FU.WhyAmIBlocked
online version:
schema: 2.0.0
---

# ConvertFrom-FUBinToXML

## SYNOPSIS
Converts appraiser .bin files to human readable XML

## SYNTAX

```
ConvertFrom-FUBinToXML [-FileList] <String[]> [-OutputPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Converts appraiser .bin files to human readable XML

## EXAMPLES

### Example 1
```powershell
PS C:\> ConvertFrom-FUBinToXML -FileList @('c:\Temp\MyFile1.Bin','c:\Temp\MyFile2.Bin') -OutputPath 'C:\Temp'
```

Converts bin files to XML and stores in OutputPath location.

## PARAMETERS

### -FileList
List of .bin files.

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

### -OutputPath
Output location for the XML files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
