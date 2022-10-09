.\Build.ps1

Import-Module ".\bin\release\FU.WhyAmIBlocked" -Force
Initialize-FUModule -reset
Get-FUBlocks


#ToDo Usage Examples
#Get-FUBlocks -DeviceName "MyDevice"
#Get-FUBlocks -AlternateSourcePath "C:\FeatureUpdateBlocks\Alt"
#Get-FUBlocksFromXML -FileList ("C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_20H1.bin_HUMANREADABLE.XML","C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_UNV.bin_HUMANREADABLE.XML")
#ConvertFrom-FUBinToXML -FileList "C:\FeatureUpdateBlocks\Alt\APPRAISER_TelemetryBaseline_20H1.bin" -OutputPath "C:\FeatureUpdateBlocks\Output"
#Extract-FUXMLFromSDB -path C:\FeatureUpdateBlocks\MyDevice
#Get-FUBlocksFromXML -FileList (Get-Item -Path "C:\FeatureUpdateBlocks\MyDevice\*human*.xml").FullName -ResultFile C:\FeatureUpdateBlocks\MyDevice\result.txt
#Export-FUBypassBlock
