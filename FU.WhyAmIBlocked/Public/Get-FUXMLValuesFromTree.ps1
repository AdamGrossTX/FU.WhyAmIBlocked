function Get-FUXMLValuesFromTree {
    [cmdletbinding()]
    param (
        $node,
        [int]$parentNodeID,
        [System.Collections.ArrayList]$Output
    )
    try {
        $i = $parentNodeID
        if($parentNodeID) {
            $Object = [pscustomobject]@{}
        }
        do{
            $obj = $node | Where-Object { $_.Name -ne '#text' -and !([string]::IsNullOrEmpty($_.'#text')) } | Select-Object Name, @{N = 'Value'; E = { $_.'#text' } }, ParentNode
            if ($obj) {
                $Object | Add-Member -MemberType NoteProperty -Name $obj.Name -Value $obj.Value -ErrorAction SilentlyContinue
                $Object | Add-Member -MemberType NoteProperty -Name "ParentNode" -Value $obj.ParentNode.SchemaInfo.Name -Force -ErrorAction SilentlyContinue
                $Object | Add-Member -MemberType NoteProperty -Name "ParentID" -Value $parentNodeID -Force -ErrorAction SilentlyContinue
            }
            if ($Node.HasChildNodes -and $Node.ChildNodes.Name -ne '#text') {
                $i++
                $return = Get-FUXMLValuesFromTree -node $Node.ChildNodes[0] -parentNodeID $i -Output $Output
                if ($return) {
                    if ($return -is [PSCustomObject]) {
                        $Output = @($return)
                    }
                    else {
                        $Output = $return
                    }
                }
            }
            if($parentNodeID) {
                $Node = $Node.NextSibling
            }
            else {
                $node = $null
            }
        }
        until (-not $Node)

        if ($Output) {
            $Output += $Object
        }
        else {
            $Output = @($Object)
        }

        return $Output
    }
    catch {
        Write-Warning $_
    }
}

