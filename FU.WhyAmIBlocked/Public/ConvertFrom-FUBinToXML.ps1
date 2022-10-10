<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
#Copy .BIN files to the share for processing...
function ConvertFrom-FUBinToXML {
    [cmdletbinding()]
    param(
        [parameter(Position = 1, Mandatory = $true)]
        [string[]]
        $FileList,

        [parameter(Position = 2, Mandatory = $true)]
        [string]
        $OutputPath
    )
    try {

        foreach ($File in $FileList) {
            $InputFile = Get-Item -Path $File
            Write-Host " + Converting $($File) to .xml .. " -ForegroundColor Cyan -NoNewline
            $XMLOutputFile = "$($OutputPath)\$($InputFile.Name)_HUMANREADABLE.XML"
            $RunList = "$($OutputPath)\RunList_$($InputFile.BaseName).xml"
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
            $system32path = "{0}\{1}" -f $env:WinDir, $(if ($env:PROCESSOR_ARCHITEW6432 -eq "ARM64") { "sysnative" }else { "system32" })
            & "$($system32path)\cmd.exe" /c "rundll32.exe appraiser.dll,RunTest $($RunListXML.FullName)"
            $RunListXML | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host $script:tick -ForegroundColor Green
        }
    }
    catch {
        Write-Warning $_
    }
}