<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
#Copy .BIN files to the share for processing...
Function ConvertFrom-BinToXML {
    [cmdletbinding()]
    Param(
        [parameter(Position = 1, Mandatory = $true)]
        [string[]]
        $FileList,

        [parameter(Position = 2, Mandatory = $true)]
        [string]
        $OutputPath
    )
        Try {

            ForEach($File in $FileList) {
                $InputFile = Get-Item -Path $File
                Write-Host " + Converting $($File) to .xml .. " -ForegroundColor Cyan -NoNewline
                $XMLOutputFile = "$($OutputPath)\$($InputFile.Name)_HUMANREADABLE.XML"
                $RunList = "$($OutputPath)\Appraiser_TelemetryRunList_$($InputFile.BaseName).xml"
                    $XML = @(
                    '<?xml version="1.0" encoding="UTF-8"?>',
                    '<WicaRun>',
                    '  <RunInfos>',
                    '    <RunInfo> ',
                    '      <Component TypeIdentifier="InventoryBinaryDeserializer" SpecificIdentifier="InventoryBinaryDeserializer" Type="Inventory">',
                    '        <Property Name="BinaryDeserializerTier" Value="Inventory" />',
                    '        <Property Name="BinaryDeserializerTier" Value="DataSource" />',
                    '        <Property Name="BinaryDeserializerTier" Value="DecisionMaker" />',
                    '        <Property Name="BinaryDeserializerTier" Value="DecisionAggregator" />',
                    "        <Property Name=`"BinaryDeserializerFilePath`" Value=`"$InputFile`" />",
                    '      </Component>',
                    '      <Component TypeIdentifier="OutputEverything" SpecificIdentifier="OutputEverything" Type="Outputter">',
                    "        <Property Name=`"OutputFilePath`" Value=`"$XMLOutputFile`" />",
                    '      </Component>',
                    '    </RunInfo>',
                    '  </RunInfos>',
                    '</WicaRun>' )

                $XML | Out-File -FilePath $RunList -Encoding utf8
                $RunListXML = Get-Item -Path $RunList -ErrorAction SilentlyContinue
                Set-Location -Path $OutputPath
                & cmd /C "rundll32.exe appraiser.dll,RunTest $($RunListXML.Name)"
                $RunListXML | Remove-Item -Force -ErrorAction SilentlyContinue
                Write-Host $script:tick -ForegroundColor Green
            }
        }
        Catch {
            Write-Warning $_
        }
    }