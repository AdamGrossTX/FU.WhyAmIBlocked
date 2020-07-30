<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
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

        Write-Host " + Finding block entries in Appraiser database.. " -ForegroundColor Cyan
        If($BlockList) {
            $BlockList = $BlockList | Select-Object -Unique
            $WorkingPath = $Path
            $Files = Get-Item -Path "$($WorkingPath)\*.sdb*.XML"
            $Blocks = @{}
            ForEach ($File in $Files) {
                Write-Host " ++ Finding block entries in $($File.FullName).. " -ForegroundColor Cyan
                [XML]$SDBContent = Get-Content -Path $File.FullName
                $AllMatches = @{}
                $Match = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {$BlockList.Contains($_.EXE_ID.'#text')}
                $MatchFile = "$($WorkingPath)\$($File.BaseName)_Matches.txt"
                ForEach($Value in $BlockList) {
                    $BlockMatch = $Match | Where-Object {$Value.Contains($_.EXE_ID.'#text')}
                    $Result = $null
                    $Result = Get-XMLValuesFromTree -node $BlockMatch -Output ( New-Object -TypeName System.Collections.ArrayList )
                    If($Result) {
                        $Blocks[$Value] = $Result
                        $AllMatches[$Value] = $Result
                    }
                
                }

                ForEach ($Key in $Blocks.Keys) {
                    $RelatedBlocks = @{}
                    $LookupValues = ($Blocks[$Key] | Where-Object {$_.Name -eq 'COMMAND_LINE' -and !([String]::IsNullOrEmpty($_.Value))}) | Where-Object Name -eq 'COMMAND_LINE'
                    If($LookupValues) {
                        $RelatedMatch = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {[Regex]::Escape($LookupValues.Value) -like [Regex]::Escape(($_.PICK_ONE.MATCH_PLUGIN.COMMAND_LINE.'#text'))} | Where-Object {$_.EXE_ID.'#text' -ne $key}
                        ForEach($Item in $RelatedMatch) {
                            $Result = $null
                            $Result = Get-XMLValuesFromTree -node $Item -Output ( New-Object -TypeName System.Collections.ArrayList )
                            If($Result) {
                                $RelatedBlocks[$Key] = $Result
                                $AllMatches[($Item.EXE_ID).'#text'] = $Result
                            }
                        }
                    }

                    "Matches for $($Key)" | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    $Blocks[$Key] | Format-Table | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    "Related Matches for $($Key)" | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    $RelatedBlocks[$Key] | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    "" | Out-File $MatchFile -Append -Encoding utf8
                    
                }

                If($AllMatches.Keys.Count -gt 0) {
                    $AllMatches | ConvertTo-Json | Out-File -FilePath "$($WorkingPath)\$($File.BaseName)_Matches.json" -Append -Encoding utf8
                    Write-Host $Script:tick -ForegroundColor green
                    Write-Host " ++ Matches output to $($MatchFile).. " -ForegroundColor green
                }
                Else {
                    Write-Host " ++No Matches Found in $($File.FullName)." -ForegroundColor Yellow
                }
            }
        }
        Else {
            Write-Host " ++No Blocklist found." -ForegroundColor Yellow
        }
    }
    Catch {
        Write-Warning $_
    }
}