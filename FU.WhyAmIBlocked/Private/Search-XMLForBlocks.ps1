Function Search-XMLForBlocks {
    [cmdletbinding()]
    Param ( 
        [parameter(Position = 1, Mandatory = $true)]
        [System.IO.FileSystemInfo]
        $InputFile,
        
        [string]
        $OutputPath = "."
    ) 
    
        [xml]$AppraiserXML = Get-Content -Path $InputFile.FullName
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
        
        Write-Progress -Activity "$InputFile ..." -Completed 
        Add-Content -Path $ResultFile -Value "$($InputFile)" -PassThru
        Add-Content -Path $ResultFile -Value "" -PassThru
        
        Do { 
            $ordinal = ($sdb[$x] | Where-Object Value -EQ 'GatedBlock').Ordinal 
            If($ordinal.Count -gt 0) { 
                Add-Content -Path $ResultFile -Value "Matching GatedBlock....FOUND!" -PassThru
                Add-Content -Path $ResultFile -Value "GatedBlock:" -PassThru
                Add-Content -Path $ResultFile -Value "==========" -PassThru
                $match = 1
            } 
            If($ordinal.Count -gt 1) { 
                $gBlock = ForEach($num in $ordinal) {
                                $sdb[$x] | Where-Object Ordinal -EQ $num
                            } 
                Add-Content -Path $ResultFile -Value "$($gBlock)" -PassThru
            }   
            If($ordinal.Count -eq 1) { 
                $gBlock = $sdb[$x] | Where-Object Ordinal -EQ $ordinal 
                Add-Content -Path $ResultFile -Value "$($gBlock)" -PassThru
            } 
    
            $x++ 
        } Until ($x -gt $sdb.Count) 
     
        If($match -ne 1) {
            Add-Content -Path $ResultFile -Value "Matching GatedBlock....NONE FOUND." -PassThru
        } 
     
        $x=0 
     
        Do {      
            $ordinal = ($sdb[$x] | Where-Object Value -EQ 'BlockUpgrade').Ordinal 
            If($ordinal.Count -gt 0) { 
                Add-Content -Path $ResultFile -Value "Matching BlockUpgrade....FOUND!" -PassThru
                Add-Content -Path $ResultFile -Value "BlockUpgrade:" -PassThru
                Add-Content -Path $ResultFile -Value "============" -PassThru
                $match = 2
            }  
            If($ordinal.Count -gt 1) { 
                $sBlock = ForEach($num in $ordinal) {
                    $sdb[$x] | Where-Object Ordinal -EQ $num
                } 
                Add-Content -Path $ResultFile -Value "$($sBlock)"  -PassThru
            }  
            Else {
                $sBlock = $sdb[$x] | Where-Object Ordinal -EQ $ordinal  
                Add-Content -Path $ResultFile -Value "$($sBlock)" -PassThru
            } 
        $x++ 
        } Until ($x -gt $sdb.Count) 
    
        If($match -ne 2){
            Add-Content -Path $ResultFile -Value "Matching Block Upgrade....NONE FOUND." -PassThru
        }
        

        Add-Content -Path $ResultFile -Value "All SDB Entries For: $($path)" -PassThru
        Add-Content -Path $ResultFile -Value "For: $($path)" -PassThru
        for($a=0; $a -lt $sdb.Count; $a++) 
            {   
                Add-Content -Path $ResultFile -Value "Entry $($a) : " -PassThru
                $sdb[$a] | Format-Table | Out-String | Add-Content -Path $ResultFile -PassThru
            } 
    }