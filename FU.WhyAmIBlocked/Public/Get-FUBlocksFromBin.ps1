<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Get-FUBlocksFromBin {
    [cmdletbinding()]
    param (
        [parameter(Position = 1, Mandatory = $true)]
        [string[]]
        $FileList,

        [string]
        $ResultFile = ".\Result.txt",

        [System.Collections.ArrayList]
        $Output
    )

    try {

        if (!(Test-Path -Path $ResultFile)) {
            New-Item -Path $ResultFile -ItemType File | Out-Null
        }
        foreach ($File in $FileList) {
            Write-Host " + Finding block entries in $($File) files.. " -ForegroundColor Cyan -NoNewline
            if (Test-Path -Path $File -ErrorAction SilentlyContinue) {
                [xml]$AppraiserXML = Get-Content -Path $File
                [System.Xml.XmlElement] $root = $AppraiserXML.get_DocumentElement()

                $i = 0 ; $s = 0 ; $sdbSearch = @() ; $sdb = @{}; $x = 0; $match = 0; $gBlock = @{}; $sBlock = @{}
                Do {
                    $datasourceValues = @()
                    $datasourceValues = $root.Assets.Asset[$i].SelectNodes("PropertyList[@Type='DataSource']")
                    if ($datasourceValues.Count -gt 0) {
                        $sdbSearch = [PSCustomObject]@{
                            SdbAppraiserData = $datasourceValues.SelectNodes("Property[@Name='SdbAppraiserData']").Value
                            SdbAppName = $datasourceValues.SelectNodes("Property[@Name='SdbAppName']").Value
                            SdbEntryGuid = $datasourceValues.SelectNodes("Property[@Name='SdbEntryGuid']").Value
                            SdbBlockType = $datasourceValues.SelectNodes("Property[@Name='SdbBlockType']").Value
                            SdbAppGuid = $datasourceValues.SelectNodes("Property[@Name='SdbAppGuid']").Value
                            SdbBlockOverrideType = $datasourceValues.SelectNodes("Property[@Name='SdbBlockOverrideType']").Value
                            SdbAppraiserData_GatedBlockId = $datasourceValues.SelectNodes("Property[@Name='SdbAppraiserData_GatedBlockId']").Value
                            Ordinal = $datasourceValues.SelectNodes("Property[@Name='SdbEntryGuid']").Ordinal
                        }
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppraiserData']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppName']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbEntryGuid']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbBlockType']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppGuid']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbBlockOverrideType']")
                        #$sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppraiserData_GatedBlockId']")                        
                        if ($sdbSearch.SdbEntryGuid) {
                            $sdb[$s] = $sdbSearch
                            $s++
                        }
                    }
                    $count = $root.Assets.Asset.Count
                    Write-Progress -Activity "Searching for Blocks - $count Items to Process" -PercentComplete (($i / $count) * 100)
                    $i++

                } Until($i -eq $count)

                Write-Progress -Activity "$File ..." -Completed
                Add-Content -Path $ResultFile -Value "$($File)"
                Add-Content -Path $ResultFile -Value ""

                Do {
                    $ordinal = ($sdb[$x] | Where-Object {$_.SdbAppraiserData -EQ 'GatedBlock'}).Ordinal
                    if ($ordinal.Count -gt 0) {
                        Add-Content -Path $ResultFile -Value "Matching GatedBlock....FOUND!"
                        Add-Content -Path $ResultFile -Value "GatedBlock:"
                        Add-Content -Path $ResultFile -Value "=========="
                        $match = 1
                    }
                    if ($ordinal.Count -gt 1) {
                        $gBlock = foreach ($num in $ordinal) {
                            $sdb[$x] | Where-Object {$_.Ordinal -eq $num}
                        }
                        $gBlock.SdbEntryGuid | foreach-Object { $Output.Add($_) | Out-Null }
                        $gBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8

                    }
                    if ($ordinal.Count -eq 1) {
                        $gBlock = $sdb[$x] | Where-Object {$_.Ordinal -eq $ordinal}
                        $gBlock.SdbEntryGuid | foreach-Object { $Output.Add($_) | Out-Null }
                        $gBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }

                    $x++
                } Until ($x -gt $sdb.Count)

                if ($match -ne 1) {
                    Add-Content -Path $ResultFile -Value "Matching GatedBlock....NONE FOUND."
                }

                $x = 0

                Do {
                    $ordinal = ($sdb[$x] | Where-Object {$_.SdbBlockType -eq 'BlockUpgrade'}).Ordinal
                    if ($ordinal.Count -gt 0) {
                        Add-Content -Path $ResultFile -Value "Matching BlockUpgrade....FOUND!"
                        Add-Content -Path $ResultFile -Value "BlockUpgrade:"
                        Add-Content -Path $ResultFile -Value "============"
                        $match = 2
                    }
                    if ($ordinal.Count -gt 1) {
                        $sBlock = foreach ($num in $ordinal) {
                            $sdb[$x] | Where-Object {$_.Ordinal -eq $num}
                        }
                        $sBlock.SdbEntryGuid | foreach-Object { $Output.Add($_) | Out-Null }
                        $sBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }
                    else {
                        $sBlock = $sdb[$x] | Where-Object {$_.Ordinal -eq $ordinal}
                        $sBlock.SdbEntryGuid | foreach-Object { $Output.Add($_) | Out-Null }
                        $sBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }
                    $x++
                } Until ($x -gt $sdb.Count)

                if ($match -ne 2) {
                    Add-Content -Path $ResultFile -Value "Matching Block Upgrade....NONE FOUND."
                }


                Add-Content -Path $ResultFile -Value "All SDB Entries For: $($path)"
                Add-Content -Path $ResultFile -Value "For: $($path)"
                for ($a = 0; $a -lt $sdb.Count; $a++) {
                    Add-Content -Path $ResultFile -Value "Entry $($a) : " | Out-Null
                    $sdb[$a] | Format-List | Out-String | Out-File -FilePath $ResultFile -Append -Encoding utf8
                }

                Write-Host $Script:tick -ForegroundColor green
            }
            else {
                Write-Warning "File not found: $($File)"
            }
        }
        Write-Host " + Results output to  $($ResultFile).. " -ForegroundColor Cyan -NoNewline
        Write-Host $Script:tick -ForegroundColor green
        return $Output | Select-Object -Unique
    }
    catch {
        Write-Warning $_
    }
}