<#
.EXTERNALHELP FU.WhyAmIBlocked-help.xml
#>
function Find-FUBlocksInSDB {
    [cmdletbinding()]
    param(

        [parameter(Position = 1, Mandatory = $false)]
        [string]
        $Path = $script:Config.Path,

        [parameter(Position = 2, Mandatory = $false)]
        [string[]]
        $BlockList = $Script:BlockList
    )

    try {

        Write-Host " + Finding block entries in Appraiser database.. " -ForegroundColor Cyan
        if ($BlockList) {
            $BlockList = $BlockList | Select-Object -Unique
            $WorkingPath = $Path
            $Files = Get-Item -Path "$($WorkingPath)\*.sdb*.XML" | Where-Object {$_ -notlike '*_ORIG*' -and $_ -notlike '*_UNV*'}
            $Blocks = @{}
            foreach ($File in $Files) {
                Write-Host " ++ Finding block entries in $($File.FullName).. " -ForegroundColor Cyan
                [XML]$SDBContent = Get-Content -Path $File.FullName
                $AllMatches = @{}
                $Match = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object { $BlockList.Contains($_.EXE_ID.'#text') }
                $MatchFile = "$($WorkingPath)\$($File.BaseName)_Matches.txt"
                foreach ($Value in $BlockList) {
                    $BlockMatch = $Match | Where-Object { $Value.Contains($_.EXE_ID.'#text') }
                    $Result = $null
                    $Result = Get-FUXMLValuesFromTree -node $BlockMatch -Output ( New-Object -TypeName System.Collections.ArrayList )
                    if ($Result) {
                        $Blocks[$Value] = $Result
                        $AllMatches[$Value] = $Result
                    }
                
                }

                foreach ($Key in $Blocks.Keys) {
                    $RelatedBlocks = @{}
                    $LookupValues = ($Blocks[$Key] | Where-Object { $_.Name -eq 'COMMAND_LINE' -and !([String]::IsNullOrEmpty($_.Value)) }) | Where-Object Name -eq 'COMMAND_LINE'
                    if ($LookupValues) {
                        $RelatedMatch = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object { [Regex]::Escape($LookupValues.Value) -like [Regex]::Escape(($_.PICK_ONE.MATCH_PLUGIN.COMMAND_LINE.'#text')) } | Where-Object { $_.EXE_ID.'#text' -ne $key }
                        foreach ($Item in $RelatedMatch) {
                            $Result = $null
                            $Result = Get-FUXMLValuesFromTree -node $Item -Output ( New-Object -TypeName System.Collections.ArrayList )
                            if ($Result) {
                                $RelatedBlocks[$Key] = $Result
                                $AllMatches[($Item.EXE_ID).'#text'] = $Result
                            }
                        }
                    }

                    "Matches for $($Key)" | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    $Blocks[$Key] | Sort-Object ParentId | Format-List | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    "Related Matches for $($Key)" | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    $RelatedBlocks[$Key] | Sort-Object ParentId | Format-List | Out-File $MatchFile -Append -Encoding utf8
                    "========================" | Out-File $MatchFile -Append -Encoding utf8
                    "" | Out-File $MatchFile -Append -Encoding utf8
                }

                if ($AllMatches.Keys.Count -gt 0) {
                    $AllMatches | Sort-Object ParentId | ConvertTo-Json | Out-File -FilePath "$($WorkingPath)\$($File.BaseName)_Matches.json" -Append -Encoding utf8
                    Write-Host $Script:tick -ForegroundColor green
                    Write-Host " ++ Matches output to $($MatchFile).. " -ForegroundColor green
                }
                else {
                    Write-Host " ++No Matches Found in $($File.FullName)." -ForegroundColor Yellow
                }
            }
        }
        else {
            Write-Host " ++No Blocklist found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning $_
    }
}