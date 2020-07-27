Function Find-BlocksInSDB {
    [cmdletbinding()]
    Param(
        
        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $script:Config.Path,
    
        [parameter(Position = 2, Mandatory = $false)]
        [string[]]
        $BlockList = $Script:BlockList
    )
    
        Try {
    
            Write-Host " + Finding block entries in Appraiser database.. " -ForegroundColor Cyan -NoNewline
            If($BlockList) {
    
                $WorkingPath = $Path
                $Files = Get-Item -Path "$($WorkingPath)\*.sdb.XML"
                $AllMatches = @{}
                $Blocks = @{}
                ForEach ($File in $Files) {
                    [XML]$SDBContent = Get-Content -Path $File.FullName
                    $Match = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {$BlockList.Contains($_.EXE_ID.'#text')}
                    ForEach($Value in $BlockList) {
                        $BlockMatch = $Match | Where-Object {$Value.Contains($_.EXE_ID.'#text')}
                        $Result = $null
                        $Result = IterateXMLTree -node $BlockMatch -Output ( New-Object -TypeName System.Collections.ArrayList )
                        If($Result) {
                            $Blocks[$Value] = $Result
                            $AllMatches[$Value] = $Result
                        }
                    }
                }
    
                ForEach ($Key in $Blocks.Keys) {
                    $RelatedBlocks = @{}
                    $LookupValues = ($Blocks[$Key] | Where-Object {$_.Name -eq 'COMMAND_LINE' -and !([String]::IsNullOrEmpty($_.Value))}) | Where Name -eq 'COMMAND_LINE'
                    If($LookupValues) {
                        $RelatedMatch = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {[Regex]::Escape($LookupValues.Value) -like [Regex]::Escape(($_.PICK_ONE.MATCH_PLUGIN.COMMAND_LINE.'#text'))} | Where-Object {$_.EXE_ID.'#text' -ne $key}
                        ForEach($Item in $RelatedMatch) {
                            $Result = $null
                            $Result = IterateXMLTree -node $Item -Output ( New-Object -TypeName System.Collections.ArrayList )
                            If($Result) {
                                $RelatedBlocks[$Key] = $Result
                                $AllMatches[($Item.EXE_ID).'#text'] = $Result
                            }
                        }
                    }
    
                    "Matches for $($Key)" | Out-File $WorkingPath\Matches.txt -Append
                    "========================" | Out-File $WorkingPath\Matches.txt -Append
                    $Blocks[$Key] | Format-Table | Out-File $WorkingPath\Matches.txt -Append
                    "========================" | Out-File $WorkingPath\Matches.txt -Append
                    "Related Matches for $($Key)" | Out-File $WorkingPath\Matches.txt -Append
                    "========================" | Out-File $WorkingPath\Matches.txt -Append
                    $RelatedBlocks[$Key] | Out-File $WorkingPath\Matches.txt -Append
                    "========================" | Out-File $WorkingPath\Matches.txt -Append 
                    "" | Out-File $WorkingPath\Matches.txt -Append
    
                }
    
                $AllMatches | ConvertTo-Json | Out-File -FilePath $WorkingPath\AllMatches.json -Append
    
                Write-Host $Script:tick -ForegroundColor green
            }
            Else {
                Write-Warning "No Blocklist found."
            }
        }
    
        Catch {
            Write-Warning $_
        }
    
    }