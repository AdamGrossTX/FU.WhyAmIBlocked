Import-Module ".\bin\release\20\FU.WhyAmIBlocked" -Force
#Update-Module FU.WhyAmIBlocked
Initialize-FUModule -reset
Get-FUBlocks

#ToDo Usage Examples
#Get-FUBlocks -DeviceName "MyDevice"
#Get-FUBlocks -AlternateSourcePath "C:\FeatureUpdateBlocks\Alt"
#Get-FUBlocksFromXML -FileList ("C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_20H1.bin_HUMANREADABLE.XML","C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_UNV.bin_HUMANREADABLE.XML")
#ConvertFrom-FUBinToXML -FileList "C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_20H1.bin" -OutputPath "C:\FeatureUpdateBlocks\Output"
#Extract-FUXMLFromSDB -path C:\FeatureUpdateBlocks\HQ-R90XC6KX
#Get-FUBlocksFromXML -FileList (Get-Item -Path "C:\FeatureUpdateBlocks\HQ-R90XC6KX\*human*.xml").FullName -ResultFile C:\FeatureUpdateBlocks\HQ-R90XC6KX\result.txt
#Export-FUBypassBlock