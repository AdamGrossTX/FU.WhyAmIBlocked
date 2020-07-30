<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
Function Get-BlocksFromBin {
    [cmdletbinding()]
    Param (
        [parameter(Position = 1, Mandatory = $true)]
        [string[]]
        $FileList,

        [string]
        $ResultFile = ".\Result.txt",

        [System.Collections.ArrayList]
        $Output
    )

    Try {

        If(!(Test-Path -Path $ResultFile)) {
            New-Item -Path $ResultFile -ItemType File | Out-Null
        }
        ForEach($File in $FileList) {
            Write-Host " + Finding block entries in $($File) files.. " -ForegroundColor Cyan -NoNewline
            If(Test-Path -Path $File -ErrorAction SilentlyContinue) {
                [xml]$AppraiserXML = Get-Content -Path $File
                [System.Xml.XmlElement] $root = $AppraiserXML.get_DocumentElement()

                $i = 0 ; $s = 0 ; $sdbSearch = @() ; $sdb = @{}; $x = 0; $match = 0; $gBlock =@{}; $sBlock = @{}
                Do {
                    $datasourceValues = @()
                    $datasourceValues = $root.Assets.Asset[$i].SelectNodes("PropertyList[@Type='DataSource']")
                    If($datasourceValues.Count -gt 0)
                        {
                            $sdbSearch = @()
                            $sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppraiserData']")
                            $sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppName']")
                            $sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbEntryGuid']")
                            $sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbBlockType']")
                            $sdbSearch += $datasourceValues.SelectNodes("Property[@Name='SdbAppGuid']")
                            If($sdbSearch.Count -gt 0)
                                {
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
                    $ordinal = ($sdb[$x] | Where-Object Value -EQ 'GatedBlock').Ordinal
                    If($ordinal.Count -gt 0) {
                        Add-Content -Path $ResultFile -Value "Matching GatedBlock....FOUND!"
                        Add-Content -Path $ResultFile -Value "GatedBlock:"
                        Add-Content -Path $ResultFile -Value "=========="
                        $match = 1
                    }
                    If($ordinal.Count -gt 1) {
                        $gBlock = ForEach($num in $ordinal) {
                                        $sdb[$x] | Where-Object Ordinal -EQ $num
                                    }
                        ($gBlock | Where-Object Name -eq "SdbEntryGuid" | Select -ExpandProperty Value) | ForEach-Object {$Output.Add($_) | Out-Null}
                        $gBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8

                    }
                    If($ordinal.Count -eq 1) {
                        $gBlock = $sdb[$x] | Where-Object Ordinal -EQ $ordinal
                        ($gBlock | Where-Object Name -eq "SdbEntryGuid" | Select -ExpandProperty Value) | ForEach-Object {$Output.Add($_) | Out-Null}
                        $gBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }

                    $x++
                } Until ($x -gt $sdb.Count)

                If($match -ne 1) {
                    Add-Content -Path $ResultFile -Value "Matching GatedBlock....NONE FOUND."
                }

                $x=0

                Do {
                    $ordinal = ($sdb[$x] | Where-Object Value -EQ 'BlockUpgrade').Ordinal
                    If($ordinal.Count -gt 0) {
                        Add-Content -Path $ResultFile -Value "Matching BlockUpgrade....FOUND!"
                        Add-Content -Path $ResultFile -Value "BlockUpgrade:"
                        Add-Content -Path $ResultFile -Value "============"
                        $match = 2
                    }
                    If($ordinal.Count -gt 1) {
                        $sBlock = ForEach($num in $ordinal) {
                            $sdb[$x] | Where-Object Ordinal -EQ $num
                        }
                        ($sBlock | Where-Object Name -eq "SdbEntryGuid" | Select -ExpandProperty Value) | ForEach-Object {$Output.Add($_) | Out-Null}
                        $sBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }
                    Else {
                        $sBlock = $sdb[$x] | Where-Object Ordinal -EQ $ordinal
                        ($sBlock | Where-Object Name -eq "SdbEntryGuid" | Select -ExpandProperty Value) | ForEach-Object {$Output.Add($_) | Out-Null}
                        $sBlock | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }
                $x++
                } Until ($x -gt $sdb.Count)

                If($match -ne 2){
                    Add-Content -Path $ResultFile -Value "Matching Block Upgrade....NONE FOUND."
                }


                Add-Content -Path $ResultFile -Value "All SDB Entries For: $($path)"
                Add-Content -Path $ResultFile -Value "For: $($path)"
                for($a=0; $a -lt $sdb.Count; $a++)
                    {
                        Add-Content -Path $ResultFile -Value "Entry $($a) : " | Out-Null
                        $sdb[$a] | Format-Table | Out-String | Out-File -FilePath $ResultFile -Append -Encoding utf8
                    }

                Write-Host $Script:tick -ForegroundColor green
            }
            Else {
                Write-Warning "File not found: $($File)"
            }
        }
        Write-Host " + Results output to  $($ResultFile).. " -ForegroundColor Cyan -NoNewline
        Write-Host $Script:tick -ForegroundColor green
        Return $Output
    }
    Catch {
        Write-Warning $_
    }
}