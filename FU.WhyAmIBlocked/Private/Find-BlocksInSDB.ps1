Function Find-BlocksInSDB {
[cmdletbinding()]
Param(
    
    [parameter(Position = 1, Mandatory = $false)]
    [string]
    $DeviceName = $env:computername,

    [parameter(Position = 2, Mandatory = $false)]
    [string]
    $Path = $script:Config.Path,

    [parameter(Position = 3, Mandatory = $false)]
    [string[]]
    $BlockValues
)

Try {

    $WorkingPath = Join-Path -Path $Path -ChildPath "$($DeviceName)"
    $Files = Get-Item -Path "$($WorkingPath)\*.sdb.XML"

    $Blocks = @{}
    ForEach ($File in $Files) {
        [XML]$SDBContent = Get-Content -Path $File.FullName
        $Match = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {$BlockValue.Contains($_.EXE_ID.'#text')}
        
        ForEach($Value in $BlockValue) {
            $BlockMatch = $Match | Where-Object {$Value.Contains($_.EXE_ID.'#text')}
            $Matches = @()
            $Result = $null
            ForEach($Node in $BlockMatch.ChildNodes) {
                $Result = $null
                $Result = IterateXMLTree -node $node
                If($Result) {
                    $Matches += $Result
                }
            }
            $Blocks[$Value] = $Matches
        }
    }

    ForEach ($Key in $Blocks.Keys) {
        $RelatedBlocks = @{}
        $LookupValues = $Blocks[$Key] | Where-Object {$_.Name -eq 'COMMAND_LINE' -and !([String]::IsNullOrEmpty($_.Value))}
        If($LookupValues) {
            $RelatedMatch = $SDBContent.SDB.Database.MATCHING_INFO_BLOCK | Where-Object {[Regex]::Escape($LookupValues.Value) -like [Regex]::Escape(($_.PICK_ONE.MATCH_PLUGIN.COMMAND_LINE.'#text'))}
            $RelatedMatch = $RelatedMatch | Where-Object {$_.EXE_ID.'#text' -ne $key}

            $RelatedMatches = @()
            $Result = $null
            ForEach($Node in $RelatedMatch.ChildNodes) {
                $Result = $null
                $Result = IterateXMLTree -node $node
                If($Result) {
                    $RelatedMatches += $Result
                }
            }
            $RelatedBlocks[$Key] = $RelatedMatches
        }

        "Matches for $($Key)" | Out-File $WorkingPath\Matches.txt -Append
        "========================" | Out-File $WorkingPath\Matches.txt -Append
        $Blocks[$Key] | Select * | Format-Table | Out-File $WorkingPath\Matches.txt -Append
        "========================" | Out-File $WorkingPath\Matches.txt -Append
        "Related Matches for $($Key)" | Out-File $WorkingPath\Matches.txt -Append
        "========================" | Out-File $WorkingPath\Matches.txt -Append
        $RelatedBlocks[$Key] | Select * | Format-Table | Out-File $WorkingPath\Matches.txt -Append
        "========================" | Out-File $WorkingPath\Matches.txt -Append 
        "" | Out-File $WorkingPath\Matches.txt -Append

    }
}
Catch {
    $Error[0]
}

}